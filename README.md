## Contributors
<a href="https://github.com/kyverno/policies/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=kyverno/policies" />
</a>

Made with [contributors-img](https://contrib.rocks).

# Policies

This repository contains Kyverno policies for a wide array of usage on various Kubernetes and ecosystem resources and subjects. For the optimal searching and browsing experience, please see [Usage and Documentation](#usage-and-documentation). For guidance on how you can contribute your own, please see [Contribution](#contribution). To request a Kyverno policy be created which doesn't exist, please see [Policy Requests](#policy-requests).

## Usage and Documentation

See https://kyverno.io/policies/ for a list of all the policies represented here in a simplified list with easy filtering abilities.

## Contribution

Anyone and everyone is welcome to write and contribute Kyverno policies! We have standardized on several practices to ensure these policies are effective, descriptive, and assist in easy location on the website. Please follow these guidelines when contributing or modifying a policy.

* As a CNCF project, Kyverno requires all contributors to abide by the DCO guidelines published [here](https://github.com/cncf/foundation/blob/main/dco-guidelines.md). This entails signing off on all git commits.

* Use the [Kyverno annotations](https://github.com/kyverno/policies/wiki/Kyverno-annotations) to mark your policy with descriptive metadata. This is not only important to explain your policy, but to allow the filtering logic on the [policies page](https://kyverno.io/policies/) to work effectively.

* Name your policy something descriptive which matches its function. Either dashes or underscores are permitted.

* Provide test resources (where possible) which allow your policy to be validated using the Kyverno CLI. See an example of a complete policy, resource, and test [here](https://github.com/kyverno/policies/tree/main/pod-security/baseline/disallow-capabilities). If unfamiliar with the Kyverno CLI and its test ability, please see the documentation [here](https://kyverno.io/docs/testing-policies/).

* For `validate` rules, please set `validationFailureAction: Audit` so that should a user download and apply the policy without having a yet full understanding of Kyverno, it will not cause unintended harm to their environment by blocking resources.

* String values do not need to be quoted nor do values which contain JMESPath expressions such as `{{request.operation}}`. The exception is if a field's value is *only* such an expression. In those cases, the JMESPath expression needs to be double quoted.

* Since Kyverno policies are made available on [Artifact Hub](https://artifacthub.io/), each new policy requires a separate metadata file. Create the `artifacthub-pkg.yml` file in the same directory as your policy. See the [Artifact Hub](#artifact-hub) section below for more details on its contents.

* A dedicated folder must be created for each policy.

* The folder must be named the same as the policy.

* Use dashes for folder name and policy name instead of underscores.

* When updating a policy already in the library, calculate the new sha256 sum of the changed policy and update the `artifacthub-pkg.yml` file's `digest` field with this value. This is to ensure Artifact Hub picks up the changes once merged.

Once your policy is written within these guidelines and tested, please open a standard PR against the `main` branch of kyverno/policies. In order for a policy to make it to the website's [policies page](https://kyverno.io/policies/), it must first be committed to the `main` branch in this repo. Following that, an administrator will render these policies to produce Markdown files in a second PR. You do not need to worry about this process, however.

In order to streamline the process, the beginning "stub" of a ClusterPolicy resource is provided below with an example of how especially the annotations should be completed. Be sure to check the documentation and other sample policies as there is no guarantee this below stub is up to date.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-capabilities
  annotations:
    policies.kyverno.io/title: Disallow Capabilities
    policies.kyverno.io/category: Pod Security Standards (Baseline)
    policies.kyverno.io/severity: medium
    kyverno.io/kyverno-version: 1.6.0
    policies.kyverno.io/minversion: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Adding capabilities beyond those listed in the policy must be disallowed.
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: my-rule-name
    match:
      any:
      - resources:
          kinds:
            - Resource
```

### Artifact Hub

Add an `artifacthub-pkg.yml` metadata file to the folder. See an example metadata file for Kyverno policies below and customize per the comments.

```yaml
---
name: backup-all-volumes # The name of the package (only alphanum, no spaces, dashes allowed)
version: 1.0.0 # Version of the policy
displayName: Backup All Volumes  # Display name of the policy
createdAt: "2023-03-29T00:00:00.000Z" # The date this package was created (RFC3339 layout)
description: >-
# The description value should be taken from the relevant annotation policies.kyverno.io/description
      In order for Velero to backup volumes in a Pod using an opt-in approach, it
      requires an annotation on the Pod called `backup.velero.io/backup-volumes` with the
      value being a comma-separated list of the volumes mounted to that Pod. This policy
      automatically annotates Pods (and Pod controllers) which refer to a PVC so that
      all volumes are listed in the aforementioned annotation if a Namespace with the label
      `velero-backup-pvc=true`.
install: |- # The installation instructions for the package
    ```shell
    kubectl apply -f https://raw.githubusercontent.com/kyverno/policies/main/velero/backup-all-volumes/backup-all-volumes.yaml
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
digest: 795012387c2755c61fa802fea900011c45520c2cffb27238210933ebb9a7f2c0 # The SHA256 hash String that uniquely identifies this package version
```

## Policy Requests

If you're not yet comfortable with Kyverno and would like to see a policy that may not presently exist, or if you're having trouble crafting that perfect policy, a couple resources exist. The most expedient way to get help may be to post on [Kyverno Slack](https://kyverno.io/community/). Kyverno has a rich and active community with its members and maintainers ready to assist. You may also [open an issue](https://github.com/kyverno/policies/issues) to request a certain policy be created to satisfy your needs. If going this route, do keep a few things in mind.

* Clearly explain in detail your use case for *why* you need a policy which isn't present on the [policies page](https://kyverno.io/policies/).

* Explain what you want this policy to do and on what resources.

* If applicable, explain what other policies and/or steps you have taken yourself that have been unsuccessful.

* Be responsive to the GitHub issue if further follow-up is required by the contributors or maintainers.

Having this information up front will assist others in crafting a policy to meet your needs.

