#!/usr/bin/env bash

. vars.env
. secrets.env # look at secrets.env.example

KUBECONFIG_CURRENT_CONTEXT=$(kubectl config current-context)
read -p "Your KUBECONFIG current context is set to '$KUBECONFIG_CURRENT_CONTEXT', do you wish to continue? [Enter/C-c] "
if [ ! $? = 0 ]; then
    echo "Exiting"
    exit 1
fi

set -x

clusterctl init --infrastructure=packet
kubectl wait -n cluster-api-provider-packet-system \
        --for=condition=ready \
        --selector=control-plane=controller-manager \
        --timeout=600s \
        pod
kubectl wait -n capi-webhook-system \
        --for=condition=ready \
        --timeout=600s \
        --selector=control-plane=controller-manager \
        pod
# Trying to avoid Error from server (InternalError): error when creating "cluster-packet-hh-humacs.yaml": Internal error occurred: failed calling webhook "default.kubeadmcontrolplane.controlplane.cluster.x-k8s.io": Post https://capi-kubeadm-control-plane-webhook-service.capi-webhook-system.svc:443/mutate-controlplane-cluster-x-k8s-io-v1alpha3-kubeadmcontrolplane?timeout=30s: dial tcp 10.103.29.156:443: connect: connection refused
kubectl create ns "$CLUSTER_NAME"
clusterctl config cluster "$CLUSTER_NAME" \
           --from ./cluster-packet-template.yaml \
           -n "$CLUSTER_NAME" \
           > cluster-packet-"$CLUSTER_NAME".yaml
kubectl -n "$CLUSTER_NAME" apply -f cluster-packet-"$CLUSTER_NAME".yaml

# wait enough for the machine to exist
kubectl wait -n $CLUSTER_NAME \
        --for=condition=Ready \
        --selector=cluster.x-k8s.io/cluster-name=$CLUSTER_NAME \
        --timeout=600s \
        machine

UUID=$(kubectl get -n $CLUSTER_NAME \
               --selector=cluster.x-k8s.io/cluster-name=$CLUSTER_NAME\
               machine \
               -o=jsonpath='{.items[0].spec.providerID}' \
           | sed sXpacket://XX)
echo "Type [ENTER] [~] [.] when you see Reached target Cloud-init target"
ssh $UUID@sos.$FACILITY.packet.net

kubectl -n "$CLUSTER_NAME" \
        get secrets "$CLUSTER_NAME"-kubeconfig \
        -o=jsonpath='{.data.value}' \
    | base64 -d > ~/.kube/packet-"$CLUSTER_NAME"
export KUBECONFIG=~/.kube/packet-"$CLUSTER_NAME"
kubectl wait -n $CLUSTER_NAME \
        --for=condition=ready \
        --selector=app.kubernetes.io/name=humacs \
        --timeout=600s pod

kubectl exec -n $CLUSTER_NAME -ti statefulset/$CLUSTER_NAME -- attach
# kubectl logs -n cluster-api-provider-packet-system \
#         --selector=control-plane=controller-manager \
#         -c manager -f
