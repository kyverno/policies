# Multitenant Kyverno policies

This Helm chart deploys Kyverno policies defined for multitenant k8s clusters. 


## Policies

| Name                                             | defined in                                | g/v/m    | a/e     | applied on    | description  |
| -------------                                    | ----------                                | -------- | -----   | ------------  | -------------|
| admin-require-annotations-or-io-type   | [annotations-adm…](/policies/helm/multitenant-kyverno-rules/templates/annotations-admin.yaml)| validate | enforce | Namespace     | Basic housekeeping to check for annotations (admins can override) |   
| admin-require-labels-or-io-type        | [labels-adm…](/policies/helm/multitenant-kyverno-rules/templates/labels-admin.yaml)| validate | enforce | Namespace     | Basic housekeeping to check for labels (admins can override) |   
| certificate-expiry-max-100days              | [certificate-exp…](/policies/helm/multitenant-kyverno-rules/templates/certificate-expiry-max-100days.yaml) | validate | enforce | Namespace     | k8s managed non letsencrypt certificates have to be renewed in every 100day | 
| block-updates-deletes-for-protected-network | [protect.yaml](/policies/helm/multitenant-kyverno-rules/templates/protect.yaml) | validate | enforce | NetworkPolicy | NetworkPolicies with `protected: "true"` label cannot be deleted |
| disallow-loadbalancer-services              | [disallow-inf…](/policies/helm/multitenant-kyverno-rules/templates/disallow-infa-services.yaml) | validate | enforce | Service       | Only allowed ClusterRoles can create LoadBalancer type services |
| disallow-nodeport-services                  | [disallow-inf…](/policies/helm/multitenant-kyverno-rules/templates/disallow-infa-services.yaml) | validate | enforce | Service       | NodePort type services cannot be created on the cluster | 
| disallow-privileged-containers              | [disallow-pri…](/policies/helm/multitenant-kyverno-rules/templates/disallow-privileged-containers.yaml) | validate | audit   | Pod           | The fields spec.containers[*].securityContext.privileged  and spec.initContainers[*].securityContext.privileged must not be set to true |
| generate-ns-quota                           | [generate-def…](/policies/helm/multitenant-kyverno-rules/templates/generate-default-requests-limits.yaml) | generate |         | NameSpace     | All new Namespaces get resource quotas defined | 
| generate-default-access                     | [generate-def…](/policies/helm/multitenant-kyverno-rules/templates/generate-default-access.yaml) | generate |         | NameSpace     | Default RoleBindings can be created for namespaces | 
| generate-net-allow-instana-access           | [generate-def…](/policies/helm/multitenant-kyverno-rules/templates/generate-default-network-policies.yaml) | generate |         | NameSpace     | All new Namespaces get a protected NetworkPolicy that enables Instana communication | 
| generate-net-default-deny-egress            | [network.yaml](/policies/helm/multitenant-kyverno-rules/templates/generate-default-network-policies.yamll) | generate |         | NameSpace     | All new Namespaces get a protected NetworkPolicy that disables default egress | 
| generate-net-default-deny-ingress           | [network.yaml](/policies/helm/multitenant-kyverno-rules/templates/generate-default-network-policies.yaml) | generate |         | NameSpace     | All new Namespaces get a protected NetworkPolicy that disables default ingress | 
| require-requests-limits                     | [require-memor…](/policies/helm/multitenant-kyverno-rules/templates/require-memory-requests-limits.yaml) | validate | enforce | Pod           | This policy validates that all containers have something specified for memory and CPU requests and memory limits |
| memory-requests-equal-limits                | [require-memor…](/policies/helm/multitenant-kyverno-rules/templates/require-memory-requests-equal-limits.yaml) | validate | audit   | Pod           | This policy checks that all containers in a given Pod have memory requests equal to limits | 
| require-annotations                         | [annotations.yaml](/policies/helm/multitenant-kyverno-rules/templates/labels.yaml) | validate | enforce | Namespace     | Basic housekeeping checks (annotations) | 
| require-labels                              | [labels.yaml](/policies/helm/multitenant-kyverno-rules/templates/labels.yaml) | validate | enforce | Namespace     | Basic housekeeping checks (labels) | 


Note: the labels and annotations to be validated are configurable through values.yaml.

# Values

The chart support the following configuration options:

| Name             | Description                                                                             |
| ----------       | -----------------                                                                       |
| active_rules     | list dictionaries defining which rules should be deployed                               |
| policy_namespace | rules custom labels will be in the {{policy_namespace}}.io namespace |
| excluded_namespaces | list of namespaces that should be excluded from enforced rules |
| label_and_annotate_resource_kinds | list of resources that should be labeled and annotated as per rules |
| label_validations | list of labels that have to be applied on the above specified resources |
| annotation_validations | list of annotations that have to be applied on the above specified resources |
| default_admin_role | default role for namespace rolebinding generation |
| default_readonly_role | default role for namespace rolebinding generation |

# Special labels

All rules are tagged with the `{{ $policy_namespace }}.io/origin: {{ $policy_namespace }}` label for easier management.

Users in the cluster-admin, admin, jenkins-ci and operator roles can bypass the validation rules if the namesapce is tagged with either the `{{ $policy_namespace }}.io/origin: system` or `{{ $policy_namespace }}.io/origin: ephemeral` label. (Names speak for themselves.)

## Generate rules

Generated network policies get the `{{ .Values.policy_namespace }}.io/protected: "true"` label that diables their deletion.

All generated resources get the `{{ .Values.policy_namespace }}.io/kyverno-generated: "true"` label for easier management.


There are three generate rules prepared for namespace creation to help automation. To control these generation rules a few special labels have been defined:

| Name                                               | Description                                                 |  Default value             |
| ----------                                         | -----------------                                           | -----------------          |
| {{ .Values.policy_namespace }}.io/admin-name       | name of the group/user to bind admin-role on this namespace |                            |
| {{ .Values.policy_namespace }}.io/admin-kind       | Group or User                                               | Group                      |
| {{ .Values.policy_namespace }}.io/admin-role       | name of the admin role                                      | {{ default_admin_role}}    |
| {{ .Values.policy_namespace }}.io/readonly-name    | name of the group/user to bind read-only  on this namespace |                            |
| {{ .Values.policy_namespace }}.io/readonly-kind    | Group or User                                               | Group                      |
| {{ .Values.policy_namespace }}.io/readonly-role    | name of the admin role                                      | {{ default_readonly_role}} |
| {{ .Values.policy_namespace }}.io/requests-cpu     | resource limit on the generated namespace                   | 1000m                      |
| {{ .Values.policy_namespace }}.io/requests-memory  | resource limit on the generated namespace                   | 1Gi                        |
| {{ .Values.policy_namespace }}.io/limits-cpu       | resource limit on the generated namespace                   | 1000m (or requests-cpu)    |
| {{ .Values.policy_namespace }}.io/limits-memory    | resource limit on the generated namespace                   | 1Gi (or requests-memory)   |


# Appendix

Query multitenant ClusterPolicies on a cluster

```
k get ClusterPolicy -l myns.io/origin=myns
```
