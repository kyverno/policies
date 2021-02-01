# Pod Security Standards

These are collections of policies which implement the various levels of Kubernetes [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

The `Baseline/Default` profile is minimally restrictive and denies the most common vulnerabilities while the `Restricted` profile is more heavily restrictive but follows many more of the common security best practices for Pods.

You can apply pod security policies by [installing Kyverno](https://kyverno.io/docs/installation/) and running:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

NOTE: The upstream `kustomize` should be used to apply customizations in these policies, available [here](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/). In many cases the version of `kustomize` built-in to `kubectl` will not work.

## Test Manifests

For each policy in both categories there is a corresponding resource which can be used to "prove" the functional state of the policy being tested. Each resource manifest is configured to violate the policy as written.

To apply the tests:

1. Install Kyverno (if needed):

```shell
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
```

2. Install policies:

```shell
 kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

3. Apply test YAMLs

```shell
 kustomize build https://github.com/kyverno/policies/pod-security/tests | kubectl apply -f -
```

All pods should be blocked from execution.

NOTE: the `proc-mount` pod may execute as non-default values for `securityContext.procMount` require the `ProcMountType` feature flag to be enabled.
