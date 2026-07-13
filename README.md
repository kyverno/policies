## Contributors
<a href="https://github.com/kyverno/policies/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=kyverno/policies" />
</a>

Made with [contributors-img](https://contrib.rocks).

# Policies

This repository contains Kyverno policies for a wide array of usage on various Kubernetes and ecosystem resources and subjects. For the optimal searching and browsing experience, please see [Usage and Documentation](#usage-and-documentation). For guidance on how you can contribute your own, please see [Contribution](#contribution). To request a Kyverno policy be created which doesn't exist, please see [Policy Requests](#policy-requests).

Policy samples use the CEL-based `policies.kyverno.io/v1` API: `ValidatingPolicy`,
`MutatingPolicy`, `GeneratingPolicy`, `DeletingPolicy`, and `ImageValidatingPolicy`.
They require Kyverno 1.17 or later; individual policies may have additional requirements.
Legacy `ClusterPolicy`, `Policy`, `ClusterCleanupPolicy`, and `CleanupPolicy` samples
have been removed, including legacy policies that used CEL validation expressions.
Test resources and third-party Kubernetes APIs are not policy samples and retain
their own API versions.

The [migration audit](.github/legacy-policy-migration.json) records every removed
sample, its immutable source revision, replacement candidates, and any behavioral
gaps. A partial replacement is not considered equivalent. See
[kyverno/kyverno#17771](https://github.com/kyverno/kyverno/issues/17771) for the complete
missing-policy checklist and per-sample remediation details.

## Usage and Documentation

See https://kyverno.io/policies/ for a list of all the policies represented here in a simplified list with easy filtering abilities.

### CEL feature samples (Kyverno 1.20)

These samples target Kyverno **1.20 (`main`)** and are based on the
[upstream CLI and conformance tests](https://github.com/kyverno/kyverno/tree/24e23f9328749fba9f9b249ce8b10c732517d9c8/test).
Each includes CLI unit tests, Chainsaw integration tests, and Artifact Hub metadata.

| Policy | Features demonstrated |
| --- | --- |
| [sync-namespace-config](other-gpol/sync-namespace-config) | Clone with `resource.Get`, selectors, source synchronization, drift repair, recreation |
| [generate-networkpolicy-targets](other-gpol/generate-networkpolicy-targets) | CEL loops, multiple targets, guarded input, generated resource synchronization |
| [generate-namespace-config-template](other-gpol/generate-namespace-config-template) | YAML templates, CEL interpolation, `generateExisting`, trigger updates |
| [cleanup-expired-configmaps](cleanup-dpol/cleanup-expired-configmaps) | Cron schedule, explicit opt-in, RFC3339 expiration with `time.now()` |
| [cleanup-completed-test-pods](cleanup-dpol/cleanup-completed-test-pods) | Namespace context, terminal Pod states, owner protection |
| [cleanup-disabled-configmaps](cleanup-dpol/cleanup-disabled-configmaps) | Resource lookups, namespace cleanup switch, protected settings |
| [verify-cosign-keyless](other-ivpol/verify-cosign-keyless) | OIDC identity, transparency log, init containers, digest pinning, Audit/Deny, Deployment autogen |
| [verify-slsa-build-type](other-ivpol/verify-slsa-build-type) | Signed SLSA v1 attestations and payload constraints |
| [verify-notary-signatures](other-ivpol/verify-notary-signatures) | Notary signatures and X.509 trust certificates |

DeletingPolicy samples are destructive and require explicit opt-in; apply their
`rbac.yaml` before their policy. A CLI deletion result of `pass` means the resource
is a deletion candidate, not that it is protected. Image policies default to
`Audit`; their integration tests switch to `Deny` to check rejection. Image tests
verify real public fixtures and require access to GHCR and Sigstore. Replace
sample trust identities, certificates, and image globs before production use.

To reproduce locally, use Docker, kind, kubectl, Go, and Chainsaw. Build the CLI
from the same `main` revision as the controllers rather than an older release.
Run the following from the repository root in Bash:

```bash
scratch="$(mktemp -d)"
export KUBECONFIG="$scratch/kubeconfig"
kind create cluster --name policy-feature-samples --image kindest/node:v1.33.1 --wait 120s
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/install-latest-testing.yaml
for controller in admission background cleanup reports; do
  kubectl rollout status -n kyverno deployment/kyverno-"$controller"-controller --timeout=180s
done
git clone --depth 1 https://github.com/kyverno/kyverno.git "$scratch/kyverno"
go build -C "$scratch/kyverno" -o "$scratch/kyverno-cli" ./cmd/cli/kubectl-kyverno

samples=(
  other-gpol/sync-namespace-config
  other-gpol/generate-networkpolicy-targets
  other-gpol/generate-namespace-config-template
  cleanup-dpol/cleanup-expired-configmaps
  cleanup-dpol/cleanup-completed-test-pods
  cleanup-dpol/cleanup-disabled-configmaps
  other-ivpol/verify-cosign-keyless
  other-ivpol/verify-slsa-build-type
  other-ivpol/verify-notary-signatures
)
"$scratch/kyverno-cli" test "${samples[@]}" --require-tests
chainsaw test "${samples[@]}" --config .chainsaw.yaml
```

Use an isolated cluster: the tests create fixed-name namespaces and cluster-scoped
policies, and delete their test resources on completion. The default kind CNI
does not enforce NetworkPolicies; these tests verify generated objects, not
network isolation. Delete the test cluster with
`kind delete cluster --name policy-feature-samples` when finished.

## Contribution

Anyone and everyone is welcome to write and contribute Kyverno policies! We have standardized on several practices to ensure these policies are effective, descriptive, and assist in easy location on the website. Please follow these guidelines when contributing or modifying a policy.

* As a CNCF project, Kyverno requires all contributors to abide by the DCO guidelines published [here](https://github.com/cncf/foundation/blob/main/policies-guidance/dco-guidelines.md). This entails signing off on all git commits.

* Use the [Kyverno annotations](https://github.com/kyverno/policies/wiki/Kyverno-annotations) to mark your policy with descriptive metadata. This is not only important to explain your policy, but to allow the filtering logic on the [policies page](https://kyverno.io/policies/) to work effectively.

* Name your policy something descriptive which matches its function. Either dashes or underscores are permitted.

* Provide test resources (where possible) which allow your policy to be validated using the Kyverno CLI. See an example of a complete policy, resource, and test [here](pod-security-vpol/baseline/disallow-capabilities). If unfamiliar with the Kyverno CLI and its test ability, please see the documentation [here](https://kyverno.io/docs/testing-policies/).

* For validating policies, please set `spec.validationActions: [Audit]` so that should a user download and apply the policy without having a yet full understanding of Kyverno, it will not cause unintended harm to their environment by blocking resources.

* Use CEL expressions in the fields supported by each policy type. YAML block scalars (`>-` or `|`) are useful for expressions containing quotes or multiple lines; legacy JMESPath template expressions are not interchangeable with CEL.

* Since Kyverno policies are made available on [Artifact Hub](https://artifacthub.io/), each new policy requires a separate metadata file. Create the `artifacthub-pkg.yml` file in the same directory as your policy. See the [Artifact Hub](#artifact-hub) section below for more details on its contents.

* A dedicated folder must be created for each policy.

* The folder must be named the same as the policy.

* Use dashes for folder name and policy name instead of underscores.

* When updating a policy already in the library, calculate the new sha256 sum of the changed policy and update the `artifacthub-pkg.yml` file's `digest` field with this value. This is to ensure Artifact Hub picks up the changes once merged. Note that because of validation checks in Kyverno's CI processes, it expects the digest to have been generated on a Linux system. Due to the differences of control characters, a digest generated from a Windows system may be different from that generated in Linux.

Once your policy is written within these guidelines and tested, please open a standard PR against the `main` branch of kyverno/policies. In order for a policy to make it to the website's [policies page](https://kyverno.io/policies/), it must first be committed to the `main` branch in this repo. Following that, an administrator will render these policies to produce Markdown files in a second PR. You do not need to worry about this process, however.

The following `ValidatingPolicy` illustrates the API, annotations, resource matching,
and a CEL validation. It audits Pods that do not have an `app` label. Consult the
other samples for the fields supported by each policy type.

```yaml
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: require-app-label
  annotations:
    policies.kyverno.io/title: Require App Label
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/minversion: 1.17.0
    kyverno.io/kubernetes-version: "1.30+"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Pods must have an app label identifying their application.
spec:
  validationActions: [Audit]
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["pods"]
  validations:
  - expression: "has(object.metadata.labels) && 'app' in object.metadata.labels"
    message: "An app label is required."
```

### Pull request automation

PR automation calls the shared workflows maintained in
[kyverno/assistant](https://github.com/kyverno/assistant/tree/main/.github/workflows),
pinned to a commit SHA. Path labeling, hourly readiness checks, and daily stale
handling run automatically and modify PRs. Manual runs default to `dry_run`
enabled, which only logs the proposed changes.

Path labels identify CEL policy types and test/documentation
changes. Readiness checks distinguish failing DCO/CI, merge conflicts, and
review threads awaiting an author response from PRs that are `ready-for-review`.
Readiness is not merge approval. Pending checks and workflows awaiting
maintainer approval do not make a PR ready.

PRs needing author action become `stale` after 7 days without a new commit and
may close after 14 days, but only after at least 7 days of warning. A new commit
resets the cycle; comments alone do not. Ready PRs receive a reviewer reminder
after 7 days instead of being closed. PRs idle for 30 days or more
(`backlog_days`) get no reviewer reminder or reviewer ping in stale warnings;
only the author is notified. Drafts and Dependabot PRs are excluded.
The labels `no-stale`, `hold`, `hold-redesign`, `blocked`, and `wip` exempt PRs
from stale handling, reviewer reminders, and readiness labels. If no reviewer or assignee is
available, reminders go to `@kyverno/policies-maintainers`.

Run **Actions > Sync labels** with `dry_run` disabled to provision or update label
metadata, including lifecycle labels. Path labels are applied only by
`pull_request_target` events (opened, reopened, synchronize), so existing PRs pick
them up on their next push; a manual **PR Labeler** run with `dry_run` disabled
refreshes only `merge-conflicts` labels. To preview changes, run **Actions > PR
lifecycle** manually with `dry_run` enabled. Definitions live in
`.github/pr-management.json`, `.github/pr-readiness-checks.yml`, and
`.github/labels.yml`. Keep the `kyverno/assistant` pin in the workflow files on a
reviewed commit SHA; `scripts/adopt-ci.sh --update-pin` in that repository opens
the update PR.

### Artifact Hub

Add an `artifacthub-pkg.yml` metadata file to the folder. See an example metadata file for Kyverno policies below and customize per the comments.

```yaml
---
name: backup-all-volumes # The name of the package (only alphanum, no spaces, dashes allowed)
version: 1.0.0 # Version of the policy
displayName: Backup All Volumes  # Display name of the policy
createdAt: "2023-03-29T00:00:00.000Z" # The date this package was created (RFC3339 layout)
# The description value should be taken from the relevant annotation policies.kyverno.io/description
description: >-
      In order for Velero to backup volumes in a Pod using an opt-in approach, it
      requires an annotation on the Pod called `backup.velero.io/backup-volumes` with the
      value being a comma-separated list of the volumes mounted to that Pod. This policy
      automatically annotates Pods (and Pod controllers) which refer to a PVC so that
      all volumes are listed in the aforementioned annotation if a Namespace with the label
      `velero-backup-pvc=true`.
install: |- # The installation instructions for the package
    ```shell
    kubectl apply -f https://raw.githubusercontent.com/kyverno/policies/main/velero-mpol/backup-all-volumes/backup-all-volumes.yaml
    ```   
keywords: # Keywords should always have "kyverno" and whatever the value of the policies.kyverno.io/category annotation. 
  - velero
  - kyverno
readme: | # readme should be same as policies.kyverno.io/description annotation plus the last sentence as a static value.
  In order for Velero to backup volumes in a Pod using an opt-in approach, it
  requires an annotation on the Pod called `backup.velero.io/backup-volumes` with the
  value being a comma-separated list of the volumes mounted to that Pod. This policy
  automatically annotates Pods (and Pod controllers) which refer to a PVC so that
  all volumes are listed in the aforementioned annotation if a Namespace with the label
  `velero-backup-pvc=true`.

  Refer to the documentation for more details on Kyverno annotations: https://artifacthub.io/docs/topics/annotations/kyverno/
annotations: # See the annotations guide on Artifact Hub here: https://artifacthub.io/docs/topics/annotations/kyverno/
  kyverno/category: "Velero"
  kyverno/kubernetesVersion: "1.25"
  kyverno/subject: "Pod, Annotation"
digest: 72ebf5e9553ce341a54de68014a72a3d6e5603e9314dcf61c7e80f236f1d7106 # The SHA256 hash String that uniquely identifies this package version
```

## Policy Requests

If you're not yet comfortable with Kyverno and would like to see a policy that may not presently exist, or if you're having trouble crafting that perfect policy, a couple resources exist. The most expedient way to get help may be to post on [Kyverno Slack](https://kyverno.io/community/). Kyverno has a rich and active community with its members and maintainers ready to assist. You may also [open an issue](https://github.com/kyverno/policies/issues) to request a certain policy be created to satisfy your needs. If going this route, do keep a few things in mind.

* Clearly explain in detail your use case for *why* you need a policy which isn't present on the [policies page](https://kyverno.io/policies/).

* Explain what you want this policy to do and on what resources.

* If applicable, explain what other policies and/or steps you have taken yourself that have been unsuccessful.

* Be responsive to the GitHub issue if further follow-up is required by the contributors or maintainers.

Having this information up front will assist others in crafting a policy to meet your needs.
