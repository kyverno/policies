#!/bin/bash
node=$(kubectl get nodes --no-headers | awk '{print $1}' | head -n 1)
if kubectl get node "$node" -o json | grep -q '"node-role.kubernetes.io/test": ""'; then
    echo "Success: node $node labelled node-role.kubernetes.io/test"
    exit 0
fi
echo "Failed to label node $node node-role.kubernetes.io/test"
exit 1
