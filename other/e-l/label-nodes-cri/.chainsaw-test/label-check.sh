#!/bin/bash
node=$(kubectl get nodes --no-headers | awk '{print $1}' | head -n 1)
containerd=$(kubectl get node "$node" -o json | kyverno jp query "pattern_match('containerd*', status.nodeInfo.containerRuntimeVersion)" | tail -n 1)
docker=$(kubectl get node "$node" -o json | kyverno jp query "pattern_match('docker*', status.nodeInfo.containerRuntimeVersion)" | tail -n 1)
if [ "$containerd" = "true" ]; then
    check=$(kubectl get node "$node" -o json | kyverno jp query "metadata.labels.runtime=='containerd'" | tail -n 1);
    if [ "$check" = "true" ]; then 
        echo "Success: node $node labelled runtime: containerd";
        exit 0;
    else
        echo "Failed to label node $node runtime: containerd";
        exit 1;
    fi;
elif [ "$docker" = "true" ]; then
    check=$(kubectl get node "$node" -o json | kyverno jp query "metadata.labels.runtime=='docker'" | tail -n 1);
    if [ "$check" = "true" ]; then 
        echo "Success: node $node labelled runtime: docker";
        exit 0;
    else
        echo "Failed to label node $node runtime: docker";
        exit 1;
    fi;
fi