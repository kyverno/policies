# Kyverno policies for OpenShift

## Policies

1. Enforce etcd encryption on OpenShift ApiServer
2. Disallow the use of OpenShift RBAC API groups. Functionality has been upstreamed to Kubernetes RBAC
3. Disallow Jenkins Pipeline Build Strategy for OpenShift Builds. Deprecated in favor of Tekton.
4. Disallow binding to the self-provisioners ClusterRoleBinding
5. Disallow the use of the SecurityContextConstraint (SCC) anyuid which allows a pod to run with the UID as declared in the image instead of a random UID
6. Disallow the use of non HTTPS OpenShift Routes

## Running Tests to verify policies

1. Install the [Kyverno CLI](https://kyverno.io/docs/kyverno-cli/).
2. Clone this repo and `cd` to it.
2. Run `kyverno-kubectl test .`.
