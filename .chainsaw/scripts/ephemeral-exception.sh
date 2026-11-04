#!/bin/sh
# Usage: ephemeral-exception.sh <policy> <denial-message> <securityContext-json> [<app-securityContext-json>]
# Verifies on a running Pod in $NAMESPACE that <policy> denies an ephemeral container with the
# given securityContext, that an image-scoped PolicyException admits it, and that an unapproved
# sibling ephemeral container is still denied.
set -eu
. "$(dirname "$0")/retry.sh"
policy=$1
message=$2
security_context=$3
app_security_context=${4:-'{}'}
pod=$policy-ephemeral-live
exception=$policy-ephemeral-image
trap 'kubectl delete policyexceptions.policies.kyverno.io "$exception" -n policy-exceptions --ignore-not-found >/dev/null' EXIT

container() {
  jq -nc --arg name "$1" --arg image "$2" --argjson sc "$security_context" '{name: $name, image: $image, securityContext: $sc}'
}
patch_ephemeral() {
  kubectl patch pod "$pod" -n "$NAMESPACE" --subresource=ephemeralcontainers --type=merge \
    --patch "$(jq -nc '{spec: {ephemeralContainers: $ARGS.positional}}' --jsonargs "$@")"
}
expect_denied() {
  if output=$(patch_ephemeral "$@" 2>&1); then
    printf 'expected %s to deny the ephemeral container, got: %s\n' "$policy" "$output" >&2
    exit 1
  fi
  printf '%s' "$output" | grep -F "$message" >/dev/null || { printf '%s\n' "$output" >&2; exit 1; }
}

kubectl create namespace policy-exceptions --dry-run=client -o yaml | kubectl apply -f -
jq -n --arg name "$pod" --argjson sc "$app_security_context" '{apiVersion: "v1", kind: "Pod", metadata: {name: $name},
  spec: {containers: [{name: "app", image: "ghcr.io/kyverno/test-busybox:1.35", command: ["sleep", "3600"], securityContext: $sc}]}}' |
  kubectl apply -n "$NAMESPACE" -f -
kubectl wait -n "$NAMESPACE" --for=jsonpath='{.status.phase}'=Running "pod/$pod" --timeout=120s

expect_denied "$(container debug nginx:1.27)"
kubectl apply -f - <<YAML
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: $exception
  namespace: policy-exceptions
spec:
  policyRefs:
  - name: $policy
    kind: ValidatingPolicy
  images: ["exempt.example/app:1"]
  matchConditions:
  - name: exact-workload
    expression: object.metadata.namespace == '$NAMESPACE' && object.metadata.name == '$pod'
YAML
# The exception needs a few seconds to reach the admission controller.
retry patch_ephemeral "$(container debug exempt.example/app:1)"
expect_denied "$(container debug exempt.example/app:1)" "$(container unapproved nginx:1.27)"
