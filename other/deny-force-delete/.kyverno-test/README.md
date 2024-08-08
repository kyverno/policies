# Kyverno CLI tests for deny-zero-grace-delete Policy

This section details the Kyverno CLI tests for the validation policy which blocks certain resources when `--grace-period=0` and `--force` is used by non cluster-admins

The test validates the `deny-force-delete.yaml` policy for both positive and negative test using the Kyverno CLI tests for the following resources:

1. Deployments
2. CronJobs
3. Pods

`values.yaml` has the `request.options.gracePeriodSeconds` information for each resource being tested along with policy/rule details. The bad and good resources are passed using the `resource.yaml` file. 

`user_info.yaml` has information about the user as this policy should block deletions only for non cluster-admins when `--grace-period=0` is used. 

`user_info_cluster-admin.yaml` is the file name to use in the `kyverno-test.yaml` when cli tests are run for `cluster-admin` user.

After applying the policy, each resource is validated against the preconfigured result specified in the `kyverno-test.yaml` and if there are any discrepancies, the test is considered as `fail`. 

Note, there is a bug where when a cluster-admin tries to delete the resources, the cli test shows `Pass (Excluded)` instead of `skip`. This is being [tracked](https://github.com/kyverno/kyverno/issues/10497) and will be fixed. We also recommend using the latest version Kyverno CLI when running the CLI tests. The CLI test for this policy was run using `v1.12.4` 

Here is the execution output of cli test with the `cluster-admin` role

```sh
$ kyverno test .
Loading test  ( kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading user infos ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 6 resources ...
  Checking results ...

│────│────────────────────────│────────────────────────│─────────────────────────────│────────│──────────│
│ ID │ POLICY                 │ RULE                   │ RESOURCE                    │ RESULT │ REASON   │
│────│────────────────────────│────────────────────────│─────────────────────────────│────────│──────────│
│ 1  │ deny-zero-grace-delete │ deny-zero-grace-delete │ Pod/badpod01                │ Pass   │ Excluded │
│ 2  │ deny-zero-grace-delete │ deny-zero-grace-delete │ Deployment/baddeployment01  │ Pass   │ Excluded │
│ 3  │ deny-zero-grace-delete │ deny-zero-grace-delete │ CronJob/badcronjob01        │ Pass   │ Excluded │
│ 4  │ deny-zero-grace-delete │ deny-zero-grace-delete │ Pod/goodpod01               │ Pass   │ Excluded │
│ 5  │ deny-zero-grace-delete │ deny-zero-grace-delete │ Deployment/gooddeployment01 │ Pass   │ Excluded │
│ 6  │ deny-zero-grace-delete │ deny-zero-grace-delete │ CronJob/goodcronjob01       │ Pass   │ Excluded │
│────│────────────────────────│────────────────────────│─────────────────────────────│────────│──────────│


Test Summary: 6 tests passed and 0 tests failed
```
