# k8s_security
Various tools for Kubernetes security

## Script to extract all namespaces/(cluster)roles/(clusterrole)bindings/resources/rights/members
* [k8s_audit_roles.bash](https://github.com/byte13/k8s_security/blob/master/k8s_audit_roles.bash)

### Tested on :
* OpenShift v4.3.1
* kubernetes v1.18.3
### Usage :
1. Copy script on some host with connection to connect to API server
2. Allow execution of the script
2. Use an account/context with at least the following rights
```
    TBS
```  
3. Launch the script
4. Retrieve the output file
