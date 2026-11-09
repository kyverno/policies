#!/bin/bash
node=$(kubectl get nodes --no-headers | awk '{print $1}' | head -n 1)
if kubectl get node "$node" -o jsonpath='{.metadata.labels.eks\.amazonaws\.com/nodegroup}' | grep -qx 'test'; then
    echo "Success: node $node labelled eks.amazonaws.com/nodegroup=test"
    exit 0
fi
echo "Failed to label node $node eks.amazonaws.com/nodegroup=test"
exit 1
