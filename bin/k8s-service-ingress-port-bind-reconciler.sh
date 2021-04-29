#!/usr/bin/env bash

[ ! -z "$SHARINGIO_PAIR_DISABLE_SVC_INGRESS_BIND_RECONCILER" ] && exit 0
if [ ! -d /var/run/secrets/kubernetes.io/serviceaccount ]; then
  echo "Unable to find Kubernetes ServiceAccount token. Please make sure that '$0' + Humacs is being run in-cluster." > /dev/stderr
  exit 1
fi

LOAD_BALANCER_IP="${SHARINGIO_PAIR_LOAD_BALANCER_IP}"

while true; do
    listening=$(ss -tunlp | grep -e ':[0-9]' | grep -E "(\*|0.0.0.0):" | awk '{print $1 " " $5 " " $7}' || true)
    svcNames=""

    while IFS= read -r line; do
        protocol=$(echo ${line} | awk '{print $1}' | grep -o '[a-z]*' | tr '[:lower:]' '[:upper:]')
        portNumber=$(echo ${line} | awk '{print $2}' | cut -d ':' -f2 | grep -o '[0-9]*')
        name=$(echo ${line} | awk '{print $3}' | cut -d '"' -f2)
        svcName="$name"
        if kubectl get ingress -l io.sharing.pair/managed=true 2> /dev/null | grep -q $name && \
            [ ! $(kubectl get ingress -l io.sharing.pair/managed=true -o json | jq -r ".items[] | select(.metadata.name==\"$name\") | .metadata.labels.\"io.sharing.pair/port\"") = "$portNumber" ]; then
            svcName="$name-$portNumber"
        fi
        hostName=$(echo "$svcName.$SHARINGIO_PAIR_BASE_DNS_NAME")

        if [ -z $name ]; then
            continue
        fi

        cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $svcName
  labels:
    io.sharing.pair/managed: "true"
    io.sharing.pair/port: "${portNumber}"
spec:
  externalIPs:
  - ${LOAD_BALANCER_IP}
  ports:
  - name: $name
    port: $portNumber
    protocol: $protocol
    targetPort: $portNumber
  selector:
    app.kubernetes.io/name: humacs
  type: ClusterIP
EOF

        if [ ! "$protocol" = "TCP" ]; then
            continue
        fi
        cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $svcName
  labels:
    io.sharing.pair/managed: "true"
    io.sharing.pair/port: "${portNumber}"
spec:
  rules:
  - host: $hostName
    http:
      paths:
      - backend:
          service:
            name: $svcName
            port:
              number: $portNumber
        path: /
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - $hostName
    secretName: letsencrypt-prod

EOF
        svcNames="$svcName $svcNames"
    done < <(echo "$listening")

    liveSvcs=$(kubectl get svc -l io.sharing.pair/managed=true -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
    while IFS= read -r line; do
        if [ -z $line ]; then
            continue
        fi
        if echo $svcNames | grep -q -E "(^| )$line( |$)"; then
            echo "live: $line"
        else
            echo "gone: $line"
            kubectl delete svc/$line || true
            kubectl delete ingress/$line || true
        fi
    done < <(echo "$liveSvcs")

    sleep 2s
done
