#!/usr/bin/env bash
. vars.env
. secrets.env # look at secrets.env.example
set -x
set -e
clusterctl init --infrastructure=packet
kubectl wait -n cluster-api-provider-packet-system \
        --for=condition=ready pod \
        --selector=control-plane=controller-manager \
        --timeout=300s
kubectl create ns "$CLUSTER_NAME"
clusterctl config cluster "$CLUSTER_NAME" \
           --from ./cluster-packet-template.yaml \
           -n "$CLUSTER_NAME" \
           > cluster-packet-"$CLUSTER_NAME".yaml
kubectl -n "$CLUSTER_NAME" apply -f cluster-packet-"$CLUSTER_NAME".yaml
# Would love to just tail these logs UNTIL the machine is active
set +x # should allow us to control-c
kubectl logs -n cluster-api-provider-packet-system \
        --selector=control-plane=controller-manager \
        -c manager -f
