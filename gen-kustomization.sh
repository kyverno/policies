#!/bin/bash
set -xeuo pipefail
for dir in ./*/; do
    dir=${dir%*/}
  if [[ -d "${dir}" && ! -L "${dir}" ]]; then
    pushd "${dir}"
    if [ ! -f ./kustomization.yaml ]; then
      cat << 'EOF' > ./kustomization.yaml
---
# yaml-language-server: $schema=https://json.schemastore.org/kustomization
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
EOF
      ls -d */ -1 | sed 's/\(.*\)\//  - .\/\1\/\1.yaml/' >> ./kustomization.yaml
    fi
    popd
  fi
done
