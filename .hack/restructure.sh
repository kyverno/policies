#!/bin/bash

set -euo pipefail

SED=sed

if [[ "$OSTYPE" == "darwin"* ]]; then
    SED=gsed
fi

rm -rf ".policies/"
rm -rf ".kyverno-tests/"

for FILE in $(find . -name "artifacthub-pkg.yml")
do
    FOLDER=$(dirname "$FILE")
    POLICY=$(basename "$FOLDER")
    POLICY_FILE="$FOLDER/$POLICY.yaml"
    mkdir -p ".policies/${FOLDER/.\//}"
    cp $POLICY_FILE ".policies/${FOLDER/.\//}"
    cp $FILE ".policies/${FOLDER/.\//}"
done

for FILE in $(find . -name "kyverno-test.yaml")
do
    FOLDER=$(dirname "$FILE")
    mkdir -p ".kyverno-tests/${FOLDER/.\//}"
    cp $FILE ".kyverno-tests/${FOLDER/.\//}"
    for NEEDED in $(cat $FILE | grep -oE "(\w|-)+\.yaml")
    do
        cp "$FOLDER/$NEEDED" ".kyverno-tests/${FOLDER/.\//}"
    done
done
