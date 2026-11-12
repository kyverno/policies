# shellcheck shell=sh
# Source from Chainsaw scripts: `. ../../../.chainsaw/scripts/retry.sh`, then `retry <command> [args...]`.
# Reruns the command (a binary or a shell function) once per second until it succeeds,
# e.g. while a PolicyException or policy change propagates to the admission controller.
retry() {
  attempt=1
  until retry_output=$("$@" 2>&1); do
    if [ "$attempt" -ge "${RETRY_ATTEMPTS:-60}" ]; then
      printf 'retry: %s failed after %s attempts; last output:\n%s\n' "$1" "$attempt" "$retry_output" >&2
      return 1
    fi
    attempt=$((attempt + 1))
    sleep 1
  done
}
