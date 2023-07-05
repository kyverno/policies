#!/bin/bash
resources=("inventory-check-ns01" "inventory-check-ns01" "inventory-check-ns02" "inventory-check-ns02" "inventory-check-ns03" "inventory-check-ns03")
rules=("resourcequotas" "networkpolicies" "resourcequotas" "networkpolicies" "resourcequotas" "networkpolicies")
results=("pass" "fail" "fail" "pass" "pass" "pass")
for i in ${!resources[@]}; do
    if [ "$(kubectl get cpolr cpol-namespace-inventory-check -o json | kyverno jp query "results[?resources[0].name=='${resources[$i]}' && rule=='${rules[$i]}'].result[?@=='${results[$i]}'] | length(@) | to_string(@)=='1'" | tail -n 1)" = "true" ] ; then
            echo Success: resource ${resources[$i]} ${results[$i]}ed for rule ${rules[$i]};
    else
            echo Failed: resource ${resources[$i]} did not ${results[$i]} for rule ${rules[$i]};
            exit 1;
    fi
done