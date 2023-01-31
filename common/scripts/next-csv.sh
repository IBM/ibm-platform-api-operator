#!/usr/bin/env bash

#
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
#

# This script needs to inputs
# The CSV version that is currently in dev

CURRENT_DEV_CSV=$1
NEW_DEV_CSV=$2
PREVIOUS_DEV_CSV=$3

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux OS
    sed -i "s/$CURRENT_DEV_CSV/$NEW_DEV_CSV/g" RELEASE_VERSION
    sed -i "s/$PREVIOUS_DEV_CSV/$CURRENT_DEV_CSV/g" PREVIOUS_VERSION

    sed -i "s/$CURRENT_DEV_CSV/$NEW_DEV_CSV/g" bundle/manifests/ibm-platform-api-operator.clusterserviceversion.yaml
    sed -i "s/$PREVIOUS_DEV_CSV/$CURRENT_DEV_CSV/g" bundle/manifests/ibm-platform-api-operator.clusterserviceversion.yaml

    sed -i "s/$CURRENT_DEV_CSV/$NEW_DEV_CSV/g" helm-charts/platform-api/Chart.yaml

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    sed -i "" "s/$CURRENT_DEV_CSV/$NEW_DEV_CSV/g" RELEASE_VERSION
    sed -i "" "s/$PREVIOUS_DEV_CSV/$CURRENT_DEV_CSV/g" PREVIOUS_VERSION

    sed -i "" "s/$CURRENT_DEV_CSV/$NEW_DEV_CSV/g" bundle/manifests/ibm-platform-api-operator.clusterserviceversion.yaml
    sed -i "" "s/$PREVIOUS_DEV_CSV/$CURRENT_DEV_CSV/g" bundle/manifests/ibm-platform-api-operator.clusterserviceversion.yaml

    sed -i "" "s/$CURRENT_DEV_CSV/$NEW_DEV_CSV/g" helm-charts/platform-api/Chart.yaml

else
    echo "Not support on other operating system"
fi