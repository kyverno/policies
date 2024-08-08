# Chainsaw tests for deny-force-delete Policy

This section details the Chainsaw tests for the validation policy that blocks deleting certain resources when `--grace-period=0` and `--force` is used by non cluster admins. 

The test has following steps:

### Step 1:

Apply the `deny-force-delete.yaml` policy and ensure that it is in the `Enforce` mode.

### Step 2:

Check the `deny-force-delete.yaml` policy and confirm the status is set to `True` and is ready.

### Step 3:

Run the policy against a `goodpod.yaml` which has resources with `gracePeriodSeconds` greater than `0`. The policy should allow these resources to go through and they will be deployed on the cluster. 

### Step 4:

Run the policy against a `badpod.yaml` which has resources with `gracePeriodSeconds` less than `1`. The policy should block these resources and generate an error which is validated in the `chainsaw-test.yaml`.
