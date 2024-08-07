# Deny Force delete

Deny deleting any resources for non-admins with "--grace-period=0 --force" option.

## Install

```sh
kubectl apply -f policies/deny-force-delete/
```

## Test

### Deploying a sample pod with nginx image

#### Sample pod yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sample-pod
  labels:
    app: nginx
spec:
  containers:
  - name: sample-container
    image: nginx:latest
```
Apply the above pod.yaml file to create a pod.

### Delete with --grace-period=0 as a non-admin user

```sh
kubectl delete pod.yaml --grace-period=0 --force
```
The above command will fail with an error for any non-admin user

### Delete with any other --grace-period duration as a non-admin user

For non-admin users, the command "kubectl delete <resource> --grace-period=duration --force" works for any other value for duration other than 0. 

Note, if the policy should block non-admin users from deleting resources when `--now` is used, the deny condition in the policy should be updated like below.

```sh
      deny:
        conditions:
          all:
          - key: "{{ request.options.gracePeriodSeconds }}"
            operator: LessThan
            value: 2
```

### Delete with any other --grace-period duration as a admin user

Admin users can delete any resource with --grace-period=0
