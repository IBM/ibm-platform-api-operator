[//]: # "Licensed Materials - Property of IBM"
[//]: # "(C) Copyright IBM Corporation 2018, 2019 All Rights Reserved"
[//]: # "US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp."

# Platform API Chart

Platform API Chart is a Helm chart made to deploy platform API services.

## Introduction

Platform API is a REST service for managing an IBM Cloud Private cluster.

## Chart Details

This Chart deploys a single instance of Platform api pod on the master node of kubernetes environment

## Prerequisites

- Kubernetes 1.11.0 or later, with beta APIs enabled
- IBM core services including auth-idp service
- Cluster Admin role for installation
- Helm version 2.9.1 or later

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

- [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)

This policy is the most restrictive, forcing pods to declare their requirements, avoiding platform or cluster-specific configuration differences.

Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive, requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster-scoped, as well as namespace-scoped, pre- and post-actions that need to occur.

The predefined SecurityContextConstraints [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is not bound to this SecurityContextConstraints resource you can bind it with the following command:

`oc adm policy add-scc-to-group ibm-restricted-scc system:serviceaccounts:<namespace>` For example, for release into the `default` namespace:
``` 
oc adm policy add-scc-to-group ibm-restricted-scc system:serviceaccounts:default
```

* Custom SecurityContextConstraints definition:

```
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: false
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
- '*'
fsGroup:
  ranges:
  - max: 65535
    min: 1
  type: MustRunAs
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    cloudpak.ibm.com/version: 1.1.0
    kubernetes.io/description: This policy is the most restrictive, requiring pods
      to run with a non-root UID, and preventing pods from accessing the host. The
      UID and GID will be bound by ranges specified at the Namespace level.
  creationTimestamp: "2019-10-30T17:52:00Z"
  generation: 1
  name: ibm-restricted-scc
  resourceVersion: "16218"
  selfLink: /apis/security.openshift.io/v1/securitycontextconstraints/ibm-restricted-scc
  uid: f97bc313-fb3d-11e9-b6a1-1696a92f80af
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- docker/default
supplementalGroups:
  ranges:
  - max: 65535
    min: 1
  type: MustRunAs
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## Resources Required

- At least 512MB of available memory

## Installing the Chart

To install the chart:

```console
$ helm install <chartname>.tgz --name platform-api --namespace ibm-common-services --tls
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```console
$ helm delete platform-api --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

Parameter                                        | Description                                               | Default
------------------------------------------------ | --------------------------------------------------------- | --------------------
`replicaCount`                                   | number of deployment replicas (Deprecated)                | 1      
`replicas`                                       | number of deployment replicas                             | 1
`platformApi.hostNetwork`                        | host network                                              | false               
`platformApi.name`                               | platformApi container name                                | platform-api        
`platformApi.image.repository`                   | platformApi image path                                    | quay.io/opencloudio/icp-platform-api   
`platformApi.image.tag`                          | platformApi image tag                                     | latest              
`platformApi.image.pullPolicy`                   | platformApi pullpolicy                                    | IfNotPresent        
`platformApi.resources.limits.cpu`               | platformApi cpu limits                                    | 500m
`platformApi.resources.limits.memory`            | platformApi memory limits                                 | 512Mi               
`platformApi.resources.requests.cpu`             | platformApi cpu requests                                  | 50m                 
`platformApi.resources.requests.memory`          | platformApi memory requests                               | 96Mi     
`platformApi.config.clusterInternalAddress`      | Cluster internal address                                  | 127.0.0.1   
`platformApi.config.etcdSecret`                  | platformApi etcd secret                                   | etcd-secret
`platformApi.config.clusterCASecret`             | Cluster CA secret name                                    | platform-api-cluster-ca-cert 
`platformApi.config.clusterExternalAddress`      | Cluster external address                                  | 127.0.0.1   
`platformApi.config.clusterSecurePort`           | cluster secure port                                       | 8443
`platformApi.config.kubeApiserverSecurePort`     | Kube API server secure port                               | 8001 
`platformApi.config.clusterName`                 | Cluster name                                              | mycluster 
`platformApi.config.clusterCAdomain`             | Cluster CA domain                                         | mycluster.icp
`platformApi.config.acctName`                    | account name                                              | mycluster account 
`auditService.image.repository`                  | audit service image path                                  | quay.io/opencloudio/audit-syslog-service   
`auditService.image.tag`                         | audit service image tag                                   | latest             
`auditService.image.pullPolicy`                  | auditService pullpolicy                                   | IfNotPresent    
`auditService.resources.limits.cpu`              | auditService cpu limits                                   | 100m
`auditService.resources.limits.memory`           | auditService memory limits                                | 512Mi               
`auditService.resources.requests.cpu`            | auditService cpu requests                                 | 50m                 
`auditService.resources.requests.memory`         | auditService memory requests                              | 256Mi  
`auditService.resources.requests.memory`         | audit service requests memory                             | 128Mi 
`auditService.config.enabled`                    | audit service container enabled                           | true        
`auditService.config.auditEnabled`               | audit service audit log generating enabled                | false           
`auditService.config.journalPath`                | audit service journal path on host node                   | /run/systemd/journal       
`auditService.config.auditLogPath`               | audit log folder in containers                            | /var/log/audit     
`auditService.config.logrotate`                  | audit service logrotate settings                          | '/var/log/audit/*.log {\n su root root\n copytruncate \n rotate 24\n hourly\n missingok\n notifempty}'                                  
`auditService.config.logrotate_conf`             | global logrotate settings                                 | include /etc/logrotate.d           

## Documentation

https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/icp_cli.html

# Limitations
