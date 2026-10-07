# Fine-grained exceptions

These samples use a `PolicyException` in the restricted `policy-exceptions` namespace. Its `matchConditions` must select the workload namespace and name; the policy predicates then consume only the listed image or value.

```yaml
apiVersion: policies.kyverno.io/v1
kind: PolicyException
metadata:
  name: allow-one-capability
  namespace: policy-exceptions
spec:
  policyRefs:
  - name: disallow-capabilities
    kind: ValidatingPolicy
  allowedValues: [SYS_ADMIN]
  matchConditions:
  - name: one-workload
    expression: object.metadata.namespace == 'team-a' && object.metadata.name == 'build-pod'
```

Use `spec.images` for a narrowly scoped container image exception; CEL reads it as `exceptions.allowedImages`. `spec.allowedValues` becomes `exceptions.allowedValues` and is policy-specific: capability names, field-qualified controls such as `control:hostNetwork`, exact host paths, decimal host ports, sysctl names, or qualified values such as `seccomp.type:Unconfined`. Every unlisted image, value, and independent validation remains enforced. A whole-resource exception is intentionally reported as `skip` and should be reserved for a complete, reviewed workload exception.

The adjacent `.kyverno-test-exceptions/kyverno-test.yaml` suite for every policy covers partial approval, wrong value/image denial, sibling isolation, and whole-resource skip. The namespace condition is part of every partial and whole exception; production RBAC should permit PolicyExceptions only in `policy-exceptions`.

Ephemeral-container updates are matched explicitly through `pods/ephemeralcontainers`. Kubernetes permits security-context fields on a newly added ephemeral container, so those fields use the same predicates. Pod-level immutable fields and container-port fields are intentionally not represented as ephemeral-update examples: Kubernetes rejects them on this subresource before policy evaluation.

The live Chainsaw scenarios install a narrow aggregation `ClusterRole` labeled `rbac.kyverno.io/aggregate-to-admission-controller: "true"` with only `get`, `list`, and `watch` on `pods/ephemeralcontainers`. Production operators must grant the equivalent permission to the Kyverno admission controller before enabling these subresource checks; policy readiness checks remain unchanged.
