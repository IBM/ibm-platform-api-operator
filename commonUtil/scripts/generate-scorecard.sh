#!/bin/bash

SCORECARD_FILE=.osdk-scorecard.yaml
CR_FILES=
CVS_FILE=

if [ -d "deploy/crds" ]; then
    CR_FILES=$(find deploy -path '*_cr.yaml' -exec echo "          - \"{}\"" \;)
fi

if [ -d "deploy/olm-catalog" ]; then
    CVS_FILE=$(find deploy/olm-catalog -path '*.clusterserviceversion.yaml' -exec echo "        csv-path: \"{}\"" \; | head -1)
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
${CVS_FILE}
EOF
