#!/usr/bin/env bash

set -e

FILES=$(find . -name "artifacthub-pkg.yml")
SED=sed

if [[ "$OSTYPE" == "darwin"* ]]; then
    SED=gsed
fi

for FILE in $FILES
do
    FOLDER=$(dirname "$FILE")
    POLICY=$(basename "$FOLDER")
    POLICY_FILE="$FOLDER/$POLICY.yaml"
    echo "Processing policy $POLICY ($POLICY_FILE) ..."
    DIGEST=$(shasum -U -a 256 "$POLICY_FILE" | cut -d" " -f 1)
    echo "  Digest: $DIGEST"
    $SED -i "s/^digest:.*/digest: $DIGEST/" $FILE
done
