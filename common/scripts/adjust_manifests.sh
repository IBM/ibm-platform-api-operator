#!/bin/bash

OPERATOR_VERSION=$1
PREVIOUS_VERSION=$2
OPERATOR_NAME=ibm-platform-api-operator
BUNDLE_DOCKERFILE_PATH=bundle.Dockerfile
BUNDLE_ANNOTATIONS_PATH=bundle/metadata/annotations.yaml
OPERANDREQUEST_PATH=config/manifests/operandrequest.json
CSV_PATH=bundle/manifests/ibm-platform-api-operator.clusterserviceversion.yaml
CHART_PATH=helm-charts/platform-api/Chart.yaml

if [[ -z "${OPERATOR_VERSION}" || -z "${PREVIOUS_VERSION}" ]]; then
    echo "Usage: $0 OPERATOR_VERSION PREVIOUS_VERSION"
    exit 1
fi

# adjust bundle.Dockerfile
if [[ -f "${BUNDLE_DOCKERFILE_PATH}" ]]; then
    echo "[INFO] Adjusting ${BUNDLE_DOCKERFILE_PATH}"
    cat ${BUNDLE_DOCKERFILE_PATH} | sed -e "s|package.v1=${OPERATOR_NAME}$|package.v1=${OPERATOR_NAME}-app|" 1<>${BUNDLE_DOCKERFILE_PATH} 
fi

# adjust annotations.yaml
if [[ -f "${BUNDLE_ANNOTATIONS_PATH}" ]]; then
    echo "[INFO] Adjusting ${BUNDLE_ANNOTATIONS_PATH}"
    cat ${BUNDLE_ANNOTATIONS_PATH} | sed -e "s|package.v1: ${OPERATOR_NAME}$|package.v1: ${OPERATOR_NAME}-app|" 1<>${BUNDLE_ANNOTATIONS_PATH}
fi

# adjust csv
if [[ -f "${CSV_PATH}" ]]; then
    echo "[INFO] Adjusting ${CSV_PATH}"

    # alm-examples
    NEW_AL_EXAMPLES_JSON=$(yq r ${CSV_PATH} metadata.annotations.alm-examples | jq ".[.|length] |= . + $(cat ${OPERANDREQUEST_PATH})")
    yq w ${CSV_PATH} "metadata.annotations.alm-examples" "${NEW_AL_EXAMPLES_JSON}" 1<>${CSV_PATH}

    # olm.skipRange
    yq w ${CSV_PATH} "metadata.annotations[olm.skipRange]" ">=3.5.0 <${OPERATOR_VERSION}" 1<>${CSV_PATH}

    # replaces
    yq w ${CSV_PATH} "spec.replaces" "${OPERATOR_NAME}.v${PREVIOUS_VERSION}" 1<>${CSV_PATH}
fi

# adjust Chart.yaml
if [[ -f "${CHART_PATH}" ]]; then
    echo "[INFO] Adjusting ${CHART_PATH}"

    # version
    yq w ${CHART_PATH} version "${OPERATOR_VERSION}" 1<>${CHART_PATH}
fi