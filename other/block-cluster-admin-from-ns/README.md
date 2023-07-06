# Explainer:
In this policy, I’ve told `Kyverno` to look for all user operations (`CREATE, UPDATE, DELETE`), on every object kind, in the testnamespace namespace, and for the `clusterRole cluster-admin`. I’ve also added the `subject User testuser` so it won’t include all the cluster-admins in the cluster.

## FYI!
1. The subject can also include groups:
```YAML
subjects:
- kind: Group
  name: my-group
```
2. Optional list of namespaces. Supports wildcards (* and ?):
```YAML
namespaces: 
 - "openshift-*"
```

# Run the following commands for testing: 
1. Create a new user (test) + grant it RBAC cluster-admin

kubectl create user testuser
kubectl adm policy add-cluster-role-to-user clusteradmin testuser
3. Test all commands with “regular” cluster-admin user

kubectl create -f pod.yaml -n testnamespace
# output: 
# pod/nginx created

kubectl edit pod ngins -n testnamespace
# output:
# pod/nginx edited

kubectl delete -f pod.yaml -n testnamespace
# output:
# pod "nginx" deleted
4. Test a command with “test” cluster-admin user

kubectl create -f pod.yaml -n testnamespace --as=testuser
# output: 
# Error from server: error when creating "test-pod.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

# policy Pod/testnamespace/nginx2 for resource violation: 

# block-cluster-admin-from-ns:
#   block-cluster-admin-from-ns: The cluster-admin 'testuser' user cannot touch testnamespace Namespace.
Note! It’s the same output for all the commands I just wanted to keep it as clean as possible

Notice that the error message is the one that I’ve written myself inside the policy, and it can be edited based on your needs!

Our pod.yaml example
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
