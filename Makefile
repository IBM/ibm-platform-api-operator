# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This repo is build locally for dev/test by default;
# Override this variable in CI env.
BUILD_LOCALLY ?= 1

# Image URL to use all building/pushing image targets;
# Use your own docker registry and image name for dev/test by overridding the IMG and REGISTRY environment variable.
IMG ?= ibm-catalog-operator
REGISTRY ?= quay.io/opencloudio

# Github host to use for checking the source tree;
# Override this variable ue with your own value if you're working on forked repo.
GIT_HOST ?= github.com/IBM

BASE_DIR := ibm-cloudctl-operator

TESTARGS_DEFAULT := "-v"
export TESTARGS ?= $(TESTARGS_DEFAULT)
DEST := $(GIT_HOST)/$(BASE_DIR)
VERSION ?= $(shell git describe --exact-match 2> /dev/null || \
                 git describe --match=$(git rev-parse --short=8 HEAD) --always --dirty --abbrev=8)

LOCAL_OS := $(shell uname)
ifeq ($(LOCAL_OS),Linux)
    TARGET_OS ?= linux
    XARGS_FLAGS="-r"
else ifeq ($(LOCAL_OS),Darwin)
    TARGET_OS ?= darwin
    XARGS_FLAGS=
else
    $(error "This system's OS $(LOCAL_OS) isn't recognized/supported")
endif

all: fmt check test build images



include commonUtil/Makefile.common.mk


############################################################
# format section
############################################################

# All available format: format-go format-protos format-python
# Default value will run all formats, override these make target with your requirements:
#    eg: fmt: format-go format-protos
fmt: format-go format-protos format-python

############################################################
# check section
############################################################

check: lint

# All available linters: lint-dockerfiles lint-scripts lint-yaml lint-copyright-banner lint-go lint-python lint-helm lint-markdown lint-sass lint-typescript lint-protos
# Default value will run all linters, override these make target with your requirements:
#    eg: lint: lint-go lint-yaml
lint: lint-all


############################################################
# build section
############################################################
ifeq ($(BUILD_LOCALLY),0)
    export CONFIG_DOCKER_TARGET = config-docker
config-docker:
endif

build: install-operator-sdk $(CONFIG_DOCKER_TARGET)
	@operator-sdk build $(REGISTRY)/$(IMG):$(VERSION)

############################################################
# images section
############################################################

images: build push-images

push-images:
	@docker tag $(REGISTRY)/$(IMG):$(VERSION) $(REGISTRY)/$(IMG)
	@if [ $(BUILD_LOCALLY) -ne 1 ]; then docker push $(REGISTRY)/$(IMG):$(VERSION); docker push $(REGISTRY)/$(IMG); fi

############################################################
# clean section
############################################################
clean:
	rm -f build/_output/bin/$(IMG)

.PHONY: all build check lint test images
