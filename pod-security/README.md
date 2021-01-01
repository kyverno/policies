# Pod Security Standards

These are collections of policies which implement the various levels of Kubernetes [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/). 

The `Baseline/Default` profile is minimally restrictive and denies the most common vulnerabilities while the `Restricted` profile is more heavily restrictive but follows many more of the common security best practices for Pods.

You can apply pod security policies by [installing Kyverno](https://kyverno.io/docs/installation/) and running:

```sh
kustomize build https://github.com/kyverno/policies/pod-security | kubectl apply -f -
```

## Test Manifests

For each policy in both categories there is a corresponding manifest which can be used to "prove" the functional state of the policy being tested. Each proof manifest is configured to violate the policy as written. In order to verify the behavior because policies are written to `audit` rather than `enforce`, the `PolicyReport` object will need to be inspected in the Namespace in which the proof manifest was deployed to check for failures. If you wish to integrate this into unit tests with less parsing logic, the policies can be configured for `enforce` mode which should block the proof manifests immediately.
