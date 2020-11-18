# IBM Platform API Operator

> **Important:** Do not install this operator directly. Only install this operator using the IBM Common Services Operator. For more information about installing this operator and other Common Services operators, see [Installer documentation](http://ibm.biz/cpcs_opinstall). If you are using this operator as part of an IBM Cloud Pak, see the documentation for that IBM Cloud Pak to learn more about how to install and use the operator service. For more information about IBM Cloud Paks, see [IBM Cloud Paks that use Common Services](http://ibm.biz/cpcs_cloudpaks).

The Platform API operator provides REST services for viewing information about your cluster, manage your cluster, download CLI tools, and much more.

For more information about the available IBM Cloud Platform Common Services, see the [IBM Knowledge Center](http://ibm.biz/cpcsdocs).

## Supported platforms

Red Hat OpenShift Container Platform 4.3 or newer installed on one of the following platforms:

- Linux x86_64
- Linux on Power (ppc64le)
- Linux on IBM Z and LinuxONE
  
## Operator versions

- 3.5.0
- 3.6.0
- 3.6.1
- 3.6.2
- 3.7.0
- 3.7.1
- 3.7.2

## Prerequisites

Before you install this operator, you need to first install the operator dependencies and prerequisites:

- For the list of operator dependencies, see the IBM Knowledge Center [Common Services dependencies documentation](http://ibm.biz/cpcs_opdependencies).

- For the list of prerequisites for installing the operator, see the IBM Knowledge Center [Preparing to install services documentation](http://ibm.biz/cpcs_opinstprereq).

## PodSecurityPolicy Requirements

See [IBM Platform API Chart README](./helm-charts/platform-api/README.md)

## Documentation

To install the operator with the IBM Common Services Operator follow the the installation and configuration instructions within the IBM Knowledge Center.

- If you are using the operator as part of an IBM Cloud Pak, see the documentation for that IBM Cloud Pak. For a list of IBM Cloud Paks, see [IBM Cloud Paks that use Common Services](http://ibm.biz/cpcs_cloudpaks).
- If you are using the operator with an IBM Containerized Software, see the IBM Cloud Platform Common Services Knowledge Center [Installer documentation](http://ibm.biz/cpcs_opinstall).

## SecurityContextConstraints Requirements

The Platform API service requires running with the OpenShift Container Platform 4.3 default privileged Security Context Constraints (SCCs).

For more information about the OpenShift Container Platform Security Context Constraints, see [Managing Security Context Constraints](https://docs.openshift.com/container-platform/4.3/authentication/managing-security-context-constraints.html).

## Developer guide

If, as a developer, you are looking to build and test this operator to try out and learn more about the operator and its capabilities, you can use the following developer guide. This guide provides commands for a quick install and initial validation for running the operator.

> **Important:** The following developer guide is provided as-is and only for trial and education purposes. IBM and IBM Support does not provide any support for the usage of the operator with this developer guide. For the official supported install and usage guide for the operator, see the the IBM Knowledge Center documentation for your IBM Cloud Pak or for IBM Cloud Platform Common Services.

### Quick start guide

Use the following quick start commands for building and testing the operator:

#### Cloning the operator repository
```
# git clone git@github.com:IBM/ibm-platform-api-operator.git
# cd ibm-platform-api-operator
```

#### Building the operator image
```
# make build
```

#### Installing the operator 
```
# make install
```

#### Uninstalling the operator
```
# make uninstall
```

### Debugging guide

Use the following commands to debug the operator:

#### Check the Cluster Service Version (CSV) installation status
```
# oc get csv
# oc describe csv ibm-platform-api-operator.v3.7.1
```

#### Check the custom resource status
```
# oc describe platformapis platform-api
# oc get platformapis platform-api -o yaml
```

#### Check the operator status and log
```
# oc describe po -l name=ibm-platform-api-operator
# oc logs -f $(oc get po -l name=ibm-platform-api-operator -o name)
```

### End-to-End testing

For more instructions on how to run end-to-end testing with the Operand Deployment Lifecycle Manager, see [ODLM guide](https://github.com/IBM/operand-deployment-lifecycle-manager/blob/master/docs/install/common-service-integration.md#end-to-end-test).