#!/bin/sh
# Usage: namespace-labels.sh save|restore <label-key>...
# save:    snapshot the given label keys on every namespace into a ConfigMap in $NAMESPACE.
# restore: reset those keys on every namespace to the snapshot (removing keys absent from it),
#          so policies that mutate existing namespaces do not leak labels into later tests.
#          Idempotent, so tests can call it from both spec.catch and the final step's cleanup.
set -eu
action=$1
shift
name=namespace-labels-snapshot

snapshot() {
  kubectl get namespaces -o json | jq -cS --args '
    [.items[] | {(.metadata.name): (.metadata.labels // {} | with_entries(select(.key | IN($ARGS.positional[]))))}] | add // {}' "$@"
}

case $action in
  save)
    kubectl create configmap "$name" --namespace "$NAMESPACE" --from-literal=snapshot="$(snapshot "$@")"
    ;;
  restore)
    saved=$(kubectl get configmap "$name" --namespace "$NAMESPACE" -o jsonpath='{.data.snapshot}')
    # Label keys and values cannot contain whitespace, so word splitting of each line is safe.
    kubectl get namespaces -o json | jq -r --argjson saved "$saved" --args '
      .items[].metadata.name as $ns
      | [$ns] + [$ARGS.positional[] as $key
          | ($saved[$ns] // {})[$key] as $value
          | if $value == null then "\($key)-" else "\($key)=\($value)" end]
      | join(" ")' "$@" |
      while read -r namespace labels; do
        # shellcheck disable=SC2086
        kubectl label namespace "$namespace" $labels --overwrite >/dev/null
      done
    current=$(snapshot "$@")
    if ! printf '%s' "$current" | jq -e --argjson saved "$saved" 'to_entries | all(.value == ($saved[.key] // {}))' >/dev/null; then
      printf 'namespace labels %s were not restored:\nsaved:   %s\ncurrent: %s\n' "$*" "$saved" "$current" >&2
      exit 1
    fi
    ;;
  *)
    printf 'usage: %s save|restore <label-key>...\n' "$0" >&2
    exit 2
    ;;
esac
