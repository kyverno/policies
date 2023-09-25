#!/bin/bash

set -euo pipefail

# Loop through each policy directory in the repository
for policy_dir in $(find "$GITHUB_WORKSPACE" -type d ! -name '.*' ! -path '*/\.*'); do
    # Skip the root directory
    if [[ "$policy_dir" == "$GITHUB_WORKSPACE" ]]; then
        continue
    fi

    # Skip directories that contain subdirectories
    if find "$policy_dir" -mindepth 1 -type d -print -quit | read; then
        # If it does, skip the filename validation
        continue
    fi

    # Get the name of the directory
    dir_name=$(basename "$policy_dir")

    # Skip if it is the CRDs directory
    if [[ $dir_name =~ ^.*CRDs.*$ ]]; then
        continue
    fi

    # Skip if it is the .hack directory
    if [[ $dir_name == ".hack" ]]; then
        continue
    fi

    # Check if the directory name only contains alphanumeric characters and dashes
    if [[ ! $dir_name =~ ^[a-zA-Z0-9-]+$ ]]; then
        echo "Directory $dir_name contains invalid characters. Only alphanumeric characters and dashes are allowed."
        exit 1
    fi

    # Skip if the directory contains a kustomization.yaml file
    if [[ -f "$policy_dir/kustomization.yaml" ]]; then
        continue
    fi

    # Check if a .yml or .yaml file with the same name as the directory exists in the directory
    if [[ ! -f "$policy_dir/$dir_name.yml" ]] && [[ ! -f "$policy_dir/$dir_name.yaml" ]]; then
        echo "No .yml or .yaml file named $dir_name found in directory $policy_dir"
        exit 1
    fi

    # Validate that artifacthub-pkg.yml or artifacthub-pkg.yaml file is found in the same folder as the policy
    if [[ ! -f "$policy_dir/artifacthub-pkg.yml" ]] && [[ ! -f "$policy_dir/artifacthub-pkg.yaml" ]]; then
        echo "artifacthub-pkg.yml or artifacthub-pkg.yaml file is not found in the same folder as the policy in directory $policy_dir"
        exit 1
    fi
done  
