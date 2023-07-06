#!/bin/bash
containerd=$(kubectl get node kind-control-plane -o json | kyverno jp query "pattern_match('containerd*', status.nodeInfo.containerRuntimeVersion)" | tail -n 1)
docker=$(kubectl get node kind-control-plane -o json | kyverno jp query "pattern_match('docker*', status.nodeInfo.containerRuntimeVersion)" | tail -n 1)
if [ "$containerd" = "true" ]; then
    check=$(kubectl get node kind-control-plane -o json | kyverno jp query "metadata.labels.runtime=='containerd'" | tail -n 1);
    if [ "$check" = "true" ]; then 
        echo "Success: node kind-control-plane labelled runtime: containerd";
        exit 0;
    else
        echo "Failed to label node kind-control-plane runtime: containerd";
        exit 1;
    fi;
elif [ "$docker" = "true" ]; then
    check=$(kubectl get node kind-control-plane -o json | kyverno jp query "metadata.labels.runtime=='docker'" | tail -n 1);
    if [ "$check" = "true" ]; then 
        echo "Success: node kind-control-plane labelled runtime: docker";
        exit 0;
    else
        echo "Failed to label node kind-control-plane runtime: docker";
        exit 1;
    fi;
fi