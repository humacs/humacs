#!/usr/bin/env bash

[ ! -z "$SHARINGIO_PAIR_DISABLE_SVC_INGRESS_BIND_RECONCILER" ] && exit 0

KUBE_CONTEXTS="$(kubectl config view -o yaml | yq e .contexts[].name -P -)"
if echo "${KUBE_CONTEXTS}" | grep -q 'in-cluster'; then
    KUBE_CONTEXT="in-cluster"
elif echo "${KUBE_CONTEXTS}" | grep -q "kubernetes-admin@${SHARINGIO_PAIR_NAME}"; then
    KUBE_CONTEXT="kubernetes-admin@${SHARINGIO_PAIR_NAME}"
fi
K8S_MINOR_VERSION="$(kubectl --context "$KUBE_CONTEXT" version --client=false -o=json 2> /dev/null | jq -r '.serverVersion.minor' | tr -dc '[0-9]')"
export SHARINGIO_PAIR_BASE_DNS_NAME=${SHARINGIO_PAIR_BASE_DNS_NAME_SVC_ING_RECONCILER_OVERRIDE:-$SHARINGIO_PAIR_BASE_DNS_NAME}

echo "Watching for processes listening on all interfaces..."

while true; do
    listening=$(ss -tunlp 2>&1 | awk '{print $1 " " $5 " " $7}' | grep -E ':[0-9]' | grep -E '(\*|0.0.0.0):' || true)
    svcNames=""

    while IFS= read -r line; do
        export protocol=$(echo ${line} | awk '{print $1}' | grep -o '[a-z]*' | tr '[:lower:]' '[:upper:]')
        export portNumber=$(echo ${line} | awk '{print $2}' | cut -d ':' -f2 | grep -o '[0-9]*')
        export pid=$(echo ${line} | sed 's/.*pid=//g' | sed 's/,.*//g')
        processName=$(echo ${line} | awk '{print $3}' | cut -d '"' -f2)
        if [ -z "$processName" ]; then
            continue
        fi
        overrideHost=$(cat /proc/$pid/environ | tr '\0' '\n' | grep SHARINGIO_PAIR_SET_HOSTNAME | cut -d '=' -f2)
        allowedPorts=$(cat /proc/$pid/environ | tr '\0' '\n' | grep SHARINGIO_PAIR_INGRESS_RECONCILER_ALLOWED_PORTS | cut -d '=' -f2)
        if [ -n "$allowedPorts" ] && ! echo ${allowedPorts[*]} | grep -q -E "(^|\(| )$portNumber( |\)|$)"; then
            echo "Skipping '$processName' (pid $pid) since port '$portNumber' is not allowed in env"
            continue
        fi
        disabledPorts=$(cat /proc/$pid/environ | tr '\0' '\n' | grep SHARINGIO_PAIR_INGRESS_RECONCILER_DISABLED_PORTS | cut -d '=' -f2)
        if [ -n "$disabledPorts" ] && echo ${disabledPorts[*]} | grep -q -E "(^|\(| )$portNumber( |\)|$)"; then
            echo "Skipping '$processName' (pid $pid) since port '$portNumber' is disabled in env"
            continue
        fi
        export name=$processName
        if [ -n "$overrideHost" ]; then
          export name=$overrideHost
        fi
        export svcName="$name"
        if kubectl --context "$KUBE_CONTEXT" get ingress -l io.sharing.pair/managed=true 2> /dev/null | grep -q $name && \
            [ ! $(kubectl --context "$KUBE_CONTEXT" get ingress -l io.sharing.pair/managed=true -o json | jq -r ".items[] | select(.metadata.name==\"$name\") | .metadata.labels.\"io.sharing.pair/port\"") = "$portNumber" ]; then
            svcName="$name-$portNumber"
        fi
        export hostName="$svcName.$SHARINGIO_PAIR_BASE_DNS_NAME"

        if [ $portNumber -lt 1000 ]; then
          export portNumber="1${portNumber}"
        fi

        envsubst < /var/local/humacs/templates/k8s-service-ingress-port-bind-reconciler/service.yaml | kubectl --context "$KUBE_CONTEXT" apply -f -

        if [ ! "$protocol" = "TCP" ]; then
            continue
        fi
        if [ $K8S_MINOR_VERSION -lt 18 ] || [ $K8S_MINOR_VERSION = 18 ];
        then
          envsubst < /var/local/humacs/templates/k8s-service-ingress-port-bind-reconciler/ingress-v1.18-or-earlier.yaml | kubectl --context "$KUBE_CONTEXT" apply -f -
        else
          envsubst < /var/local/humacs/templates/k8s-service-ingress-port-bind-reconciler/ingress.yaml | kubectl --context "$KUBE_CONTEXT" apply -f -
        fi

        svcNames="$svcName $svcNames"
    done < <(echo "$listening")

    liveSvcs=$(kubectl --context "$KUBE_CONTEXT" get svc -l io.sharing.pair/managed=true -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
    while IFS= read -r line; do
        if [ -z $line ]; then
            continue
        fi
        if echo $svcNames | grep -q -E "(^| )$line( |$)"; then
            echo "live: $line"
        else
            echo "gone: $line"
            kubectl --context "$KUBE_CONTEXT" delete svc/$line || true
            kubectl --context "$KUBE_CONTEXT" delete ingress/$line || true
        fi
    done < <(echo "$liveSvcs")

    sleep 2s
done
