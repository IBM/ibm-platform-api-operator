#!/bin/bash

CSV_VERSION=$1
SCORECARD_FILE=.osdk-scorecard.yaml
CR_FILES=
CSV_FILE=

if [ -d "deploy/crds" ]; then
    CR_FILES=$(find deploy -path '*_cr.yaml' -exec echo "          - \"{}\"" \;)
fi

if [ -d "deploy/olm-catalog" ]; then
    CSV_FILE=$(find deploy/olm-catalog -path "*${CSV_VERSION}*.clusterserviceversion.yaml" -exec echo "        csv-path: \"{}\"" \; | tail -1)
fi

cat <<EOF >${SCORECARD_FILE}
scorecard:
  # Setting a global scorecard option
  output: json
  plugins:
    # basic tests configured to test CRs
    - basic:
        cr-manifest:
${CR_FILES}
    # olm tests configured to test CRs
    - olm:
        cr-manifest:
${CR_FILES}
${CSV_FILE}
EOF
