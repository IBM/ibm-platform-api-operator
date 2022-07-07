# Copyright 2022 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.DEFAULT_GOAL:=help

# Dependence tools
CONTAINER_CLI ?= $(shell basename $(shell which docker))
KUBECTL ?= $(shell which kubectl)
OPERATOR_SDK ?= $(shell which operator-sdk)
OPM ?= $(shell which opm)
KUSTOMIZE ?= $(shell which kustomize)
KUSTOMIZE_VERSION=v3.8.7
HELM_OPERATOR_VERSION=v1.3.0
OPM_VERSION=v1.15.2
YQ_VERSION=3.4.1
JQ_VERSION=1.6
OPERATOR_SDK_VERSION=v1.20.0

# Specify whether this repo is build locally or not, default values is '1';
# If set to 1, then you need to also set 'DOCKER_USERNAME' and 'DOCKER_PASSWORD'
# environment variables before build the repo.
BUILD_LOCALLY ?= 1

VCS_URL = $(shell git config --get remote.origin.url)
VCS_REF ?= $(shell git rev-parse HEAD)
RELEASE_VERSION ?= $(shell cat RELEASE_VERSION)
PREVIOUS_VERSION ?= $(shell cat PREVIOUS_VERSION)
VERSION ?= $(shell git describe --exact-match 2> /dev/null || \
                git describe --match=$(git rev-parse --short=8 HEAD) --always --dirty --abbrev=8)
LOCAL_OS := $(shell uname)
ifeq ($(LOCAL_OS),Linux)
    TARGET_OS ?= linux
    XARGS_FLAGS="-r"
	STRIP_FLAGS=
else ifeq ($(LOCAL_OS),Darwin)
    TARGET_OS ?= darwin
    XARGS_FLAGS=
	STRIP_FLAGS="-x"
else
    $(error "This system's OS $(LOCAL_OS) isn't recognized/supported")
endif

ARCH := $(shell uname -m)
LOCAL_ARCH := "amd64"
ifeq ($(ARCH),x86_64)
    LOCAL_ARCH="amd64"
else ifeq ($(ARCH),ppc64le)
    LOCAL_ARCH="ppc64le"
else ifeq ($(ARCH),s390x)
    LOCAL_ARCH="s390x"
else
    $(error "This system's ARCH $(ARCH) isn't recognized/supported")
endif

# Current Operator image name
OPERATOR_IMAGE_NAME ?= ibm-platform-api-operator
# Current Operator bundle image name
BUNDLE_IMAGE_NAME ?= ibm-platform-api-operator-bundle

# Options for 'bundle-build'
ifneq ($(origin CHANNELS), undefined)
BUNDLE_CHANNELS := --channels=$(CHANNELS)
endif
ifneq ($(origin DEFAULT_CHANNEL), undefined)
BUNDLE_DEFAULT_CHANNEL := --default-channel=$(DEFAULT_CHANNEL)
endif
BUNDLE_METADATA_OPTS ?= $(BUNDLE_CHANNELS) $(BUNDLE_DEFAULT_CHANNEL)

ifeq ($(BUILD_LOCALLY),0)
    export CONFIG_DOCKER_TARGET = config-docker
	# Default image repo
	REGISTRY ?= hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com/ibmcom
else
	REGISTRY ?= hyc-cloud-private-scratch-docker-local.artifactory.swg-devops.com/ibmcom
endif

include common/Makefile.common.mk

############################################################
##@ Develement tools
############################################################

OS    = $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  = $(shell uname -m | sed 's/x86_64/amd64/')
OSOPER   = $(shell uname -s | tr '[:upper:]' '[:lower:]' | sed 's/darwin/apple-darwin/' | sed 's/linux/linux-gnu/')
ARCHOPER = $(shell uname -m )

tools: kustomize helm-operator opm yq ## Install all development tools

kustomize: ## Install kustomize
ifeq (, $(shell which kustomize 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	echo "Downloading kustomize ...";\
	curl -sSLo - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/$(KUSTOMIZE_VERSION)/kustomize_$(KUSTOMIZE_VERSION)_$(OS)_$(ARCH).tar.gz | tar xzf - -C bin/ ;\
	}
KUSTOMIZE=$(realpath ./bin/kustomize)
else
KUSTOMIZE=$(shell which kustomize)
endif

operator-sdk: ## Install operator-sdk
ifneq ($(shell operator-sdk version | cut -d ',' -f1 | cut -d ':' -f2 | tr -d '"' | xargs | cut -d '.' -f1), v1)
	@{ \
	if [ "$(shell ./bin/operator-sdk version | cut -d ',' -f1 | cut -d ':' -f2 | tr -d '"' | xargs)" != $(OPERATOR_SDK_VERSION) ]; then \
		set -e ; \
		mkdir -p bin ;\
		echo "Downloading operator-sdk..." ;\
		curl -sSLo ./bin/operator-sdk "https://github.com/operator-framework/operator-sdk/releases/download/$(OPERATOR_SDK_VERSION)/operator-sdk_$(LOCAL_OS)_$(LOCAL_ARCH)" ;\
		chmod +x ./bin/operator-sdk ;\
	fi ;\
	}
OPERATOR_SDK=$(realpath ./bin/operator-sdk)
else
OPERATOR_SDK=$(shell which operator-sdk)
endif

helm-operator: ## Install helm-operator
ifeq (, $(shell which helm-operator 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	echo "Downloading helm-operator ...";\
	curl -LO https://github.com/operator-framework/operator-sdk/releases/download/$(HELM_OPERATOR_VERSION)/helm-operator-$(HELM_OPERATOR_VERSION)-$(ARCHOPER)-$(OSOPER) ;\
	mv helm-operator-$(HELM_OPERATOR_VERSION)-$(ARCHOPER)-$(OSOPER) ./bin/helm-operator ;\
	chmod +x ./bin/helm-operator ;\
	}
HELM_OPERATOR=$(realpath ./bin/helm-operator)
else
HELM_OPERATOR=$(shell which helm-operator)
endif

opm: ## Install operator registry opm
ifeq (, $(shell which opm 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	echo "Downloading opm ...";\
	curl -LO https://github.com/operator-framework/operator-registry/releases/download/$(OPM_VERSION)/$(OS)-amd64-opm ;\
	mv $(OS)-amd64-opm ./bin/opm ;\
	chmod +x ./bin/opm ;\
	}
OPM=$(realpath ./bin/opm)
else
OPM=$(shell which opm)
endif

yq: ## Install yq, a yaml processor
ifeq (, $(shell which yq 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	$(eval ARCH := $(shell uname -m|sed 's/x86_64/amd64/')) \
	echo "Downloading yq ...";\
	curl -LO https://github.com/mikefarah/yq/releases/download/$(YQ_VERSION)/yq_$(OS)_$(ARCH);\
	mv yq_$(OS)_$(ARCH) ./bin/yq ;\
	chmod +x ./bin/yq ;\
	}
YQ=$(realpath ./bin/yq)
else
YQ=$(shell which yq)
endif

jq: ## Install jq, a yaml processor
ifeq (, $(shell which jq 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	$(eval ARCH := $(shell uname -m|sed 's/x86_64/64/')) \
	echo "Downloading jq ...";\
	curl -LO https://github.com/stedolan/jq/releases/download/jq-$(JQ_VERSION)/jq-$(OS)$(ARCH);\
	mv jq-$(OS)$(ARCH) ./bin/jq ;\
	chmod +x ./bin/jq ;\
	}
JQ=$(realpath ./bin/jq)
else
JQ=$(shell which jq)
endif

############################################################
##@ Development
############################################################

check: lint-all ## Check all files lint error
	./common/scripts/lint-csv.sh

run: helm-operator ## Run against the configured Kubernetes cluster in ~/.kube/config
	$(HELM_OPERATOR) run

install: kustomize ## Install CRDs into a cluster
	$(KUSTOMIZE) build config/crd | kubectl apply -f -

uninstall: kustomize ## Uninstall CRDs from a cluster
	$(KUSTOMIZE) build config/crd | kubectl delete -f -

deploy: kustomize ## Deploy controller in the configured Kubernetes cluster in ~/.kube/config
	- kubectl apply -f config/rbac/serviceaccount.yaml
	$(KUSTOMIZE) build config/development | kubectl apply -f -
	$(KUSTOMIZE) build config/samples | kubectl apply -f -

undeploy: kustomize ## Undeploy controller in the configured Kubernetes cluster in ~/.kube/config
	$(KUSTOMIZE) build config/samples | kubectl delete -f -
	$(KUSTOMIZE) build config/development | kubectl delete -f -
	- kubectl delete -f config/rbac/serviceaccount.yaml

clean-cluster: ## Clean up all the resources left in the Kubernetes cluster
	@echo ....... Cleaning up .......
	- kubectl get platformapis -o name | xargs kubectl delete
	- kubectl get csv -o name | grep platform-api | xargs kubectl delete
	- kubectl get sub -o name | grep platform-api | xargs kubectl delete
	- kubectl get installplans | grep platform-api | awk '{print $$1}' | xargs kubectl delete installplan
	- kubectl get serviceaccounts -o name | grep platform-api | xargs kubectl delete
	- kubectl get clusterrole -o name | grep platform-api | xargs kubectl delete
	- kubectl get clusterrolebinding -o name | grep platform-api | xargs kubectl delete	
	- kubectl get crd -o name | grep platformapi | xargs kubectl delete

global-pull-secrets: ## Update global pull secrets to use artifactory registries
	./common/scripts/update_global_pull_secrets.sh

deploy-catalog: build-catalog ## Deploy the operator bundle catalogsource for testing
	./common/scripts/update_catalogsource.sh $(OPERATOR_IMAGE_NAME) $(REGISTRY)/$(OPERATOR_IMAGE_NAME)-catalog:$(RELEASE_VERSION)

undeploy-catalog: ## Undeploy the operator bundle catalogsource
	- kubectl -n openshift-marketplace delete catalogsource $(OPERATOR_IMAGE_NAME)

run-bundle:
	$(OPERATOR_SDK) run bundle $(REGISTRY)/$(BUNDLE_IMAGE_NAME)-$(ARCH):$(RELEASE_VERSION) --pull-secret-name pull-secret-copy
	$(KUBECTL) apply -f config/samples/operator_v1alpha1_platformapi.yaml

upgrade-bundle:
	$(OPERATOR_SDK) run bundle-upgrade $(REGISTRY)/$(BUNDLE_IMAGE_NAME)-$(ARCH):dev

cleanup-bundle:
	$(OPERATOR_SDK) cleanup ibm-platform-api-operator-app

############################################################
##@ Test
############################################################

test: ## Run unit test on prow
	@echo good

############################################################
##@ Build
############################################################

build-dev: build-image-dev ## Build operator image for development

build-catalog: build-bundle-image build-catalog-source ## Build bundle image and catalog source image for development

# Build bundle image
build-bundle-image:
	$(eval ARCH := $(shell uname -m|sed 's/x86_64/amd64/'))
	@cp -f bundle/manifests/ibm-platform-api-operator.clusterserviceversion.yaml /tmp/ibm-platform-api-operator.clusterserviceversion.yaml
	@$(YQ) d -i bundle/manifests/ibm-platform-api-operator.clusterserviceversion.yaml "spec.replaces"
	$(CONTAINER_CLI) build -f bundle.Dockerfile -t $(REGISTRY)/$(BUNDLE_IMAGE_NAME)-$(ARCH):$(RELEASE_VERSION) .
	$(CONTAINER_CLI) push $(REGISTRY)/$(BUNDLE_IMAGE_NAME)-$(ARCH):$(RELEASE_VERSION)
	@mv /tmp/ibm-platform-api-operator.clusterserviceversion.yaml bundle/manifests/ibm-platform-api-operator.clusterserviceversion.yaml

# Build catalog source
build-catalog-source:
	$(OPM) -u $(CONTAINER_CLI) index add --bundles $(REGISTRY)/$(BUNDLE_IMAGE_NAME)-$(ARCH):$(RELEASE_VERSION) --tag $(REGISTRY)/$(OPERATOR_IMAGE_NAME)-catalog:$(RELEASE_VERSION)
	$(CONTAINER_CLI) push $(REGISTRY)/$(OPERATOR_IMAGE_NAME)-catalog:$(RELEASE_VERSION)

# Build image for development
build-image-dev: $(CONFIG_DOCKER_TARGET)
	$(eval ARCH := $(shell uname -m|sed 's/x86_64/amd64/'))
	$(CONTAINER_CLI) build -t $(REGISTRY)/$(OPERATOR_IMAGE_NAME)-$(ARCH):dev \
	--build-arg VCS_REF=$(VCS_REF) --build-arg VCS_URL=$(VCS_URL) \
	-f Dockerfile .
	$(CONTAINER_CLI) push $(REGISTRY)/$(OPERATOR_IMAGE_NAME)-$(ARCH):dev

# Build image
build-operator-image: $(CONFIG_DOCKER_TARGET) ## Build the operator image.
	@echo "Building the $(OPERATOR_IMAGE_NAME) docker image for $(LOCAL_ARCH)..."
	$(CONTAINER_CLI) build -t $(OPERATOR_IMAGE_NAME)-$(LOCAL_ARCH):$(VERSION) \
	--build-arg VCS_REF=$(VCS_REF) --build-arg VCS_URL=$(VCS_URL) \
	-f Dockerfile .

# Build and Push image
build-push-image: $(CONFIG_DOCKER_TARGET) build-operator-image  ## Build and push the operator images.
	@echo "Pushing the $(OPERATOR_IMAGE_NAME) docker image for $(LOCAL_ARCH)..."
	@docker tag $(OPERATOR_IMAGE_NAME)-$(LOCAL_ARCH):$(VERSION) $(REGISTRY)/$(OPERATOR_IMAGE_NAME)-$(LOCAL_ARCH):$(VERSION)
	@docker push $(REGISTRY)/$(OPERATOR_IMAGE_NAME)-$(LOCAL_ARCH):$(VERSION)

############################################################
##@ Release
############################################################

bundle: kustomize operator-sdk yq jq ## Generate bundle manifests and metadata, then validate the generated files
	$(OPERATOR_SDK) generate kustomize manifests -q
	- make bundle-manifests CHANNELS=beta,stable-v1 DEFAULT_CHANNEL=stable-v1

bundle-manifests:
	$(KUSTOMIZE) build config/manifests | $(OPERATOR_SDK) generate bundle \
	-q --overwrite --version $(RELEASE_VERSION) $(BUNDLE_METADATA_OPTS)
	$(OPERATOR_SDK) bundle validate ./bundle
	@./common/scripts/adjust_manifests.sh $(YQ) $(JQ) $(RELEASE_VERSION) $(PREVIOUS_VERSION) 

multiarch-image: $(CONFIG_DOCKER_TARGET)
	@MAX_PULLING_RETRY=20 RETRY_INTERVAL=30 common/scripts/multiarch_image.sh $(REGISTRY) $(OPERATOR_IMAGE_NAME) $(VERSION) $(RELEASE_VERSION)

############################################################
##@ Help
############################################################
help: ## Display this help
	@echo "Usage:\n  make \033[36m<target>\033[0m"
	@awk 'BEGIN {FS = ":.*##"}; \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)