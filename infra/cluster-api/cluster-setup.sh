#!/usr/bin/env bash
. vars.env
. secrets.env # look at secrets.env.example
set -x
#set -e
clusterctl init --infrastructure=packet
kubectl wait -n cluster-api-provider-packet-system \
        --for=condition=ready \
        --selector=control-plane=controller-manager \
        --timeout=300s \
        pod
kubectl wait -n capi-webhook-system \
        --for=condition=Available \
        --timeout=300s \
        deployment/capi-kubeadm-control-plane-controller-manager
kubectl create ns "$CLUSTER_NAME"
clusterctl config cluster "$CLUSTER_NAME" \
           --from ./cluster-packet-template.yaml \
           -n "$CLUSTER_NAME" \
           > cluster-packet-"$CLUSTER_NAME".yaml
kubectl -n "$CLUSTER_NAME" apply -f cluster-packet-"$CLUSTER_NAME".yaml
sleep 15 # wait enough for the machine to exist
kubectl wait -n $CLUSTER_NAME \
        --for=condition=Ready \
        --selector=cluster.x-k8s.io/cluster-name=$CLUSTER_NAME \
        --timeout=300s \
        machine
UUID=$(kubectl get -n $CLUSTER_NAME \
               --selector=cluster.x-k8s.io/cluster-name=$CLUSTER_NAME\
               machine \
               -o=jsonpath='{.items[0].spec.providerID}' \
           | sed sXpacket://XX)
echo "Type [~] [ENTER] [.] when you see Reached target Cloud-init target"
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
