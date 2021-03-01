# How to test changes
This document assumes you will be using personal quay.io registry to push bundle and operator images to avoid accidentally changing production registries
```
export REGISTRY=quay.io/<your_namespace>
```

If pushing an image to your quay.io registry with its first tag, the image repository may be set to private by default, so you will need to login to quay.io and change the repository settings to public in order for your cluster to pull the image.

The actual testing consist of:
1. verify operator pod is Running
2. verify operand pod is Running
3. run `cloudctl login` successfully
4. run `cloudctl version` and verify server version is expected value

## Test fresh installation with bundle
1. add features/fixes to repo
2. change `image` value in config/manager/manager.yaml to `quay.io/<your_namespace>/ibm-platform-api-operator-amd64:dev`
   - and any of the operand image values if necessary
3. build operator with changes
```
make build-dev
```
4. build bundle containing changes and bundle image
```
make bundle VERSION=99.99.99
make build-bundle-image VERSION=dev
```
5. deploy operator using bundle format
```
make run-bundle VERSION=dev
```
6. run tests
7. clean up
```
make cleanup-bundle
```

## Test upgrade with bundle
Similar to fresh installation test except you will first deploy the operator/bundle of the most recent release without any changes, i.e. the operator/bundle code from the most recent commit in master branch

1. build bundle and bundle image without any changes
```
make bundle
make build-bundle-image
```
2. deploy unchanged operator using bundle format
```
make run-bundle
```
3. add features/fixes to repo
4. change `image` value in config/manager/manager.yaml to `quay.io/<your_namespace>/ibm-platform-api-operator-amd64:dev`
   - and any of the operand image values if necessary
5. build operator with changes
```
make build-dev
```
6. upgrade operator
```
make upgrade-bundle
```
7. run tests
8. clean up
```
make cleanup-bundle
```
