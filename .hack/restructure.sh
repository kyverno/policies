#!/bin/bash

set -euo pipefail

SED=sed

if [[ "$OSTYPE" == "darwin"* ]]; then
    SED=gsed
fi

rm -rf ".policies/"
rm -rf ".kyverno-tests/"

# for FILE in $(find . -name "artifacthub-pkg.yml")
# do
#     FOLDER=$(dirname "$FILE")
#     POLICY=$(basename "$FOLDER")
#     POLICY_FILE="$FOLDER/$POLICY.yaml"
#     mkdir -p ".policies/${FOLDER/.\//}"
#     cp $POLICY_FILE ".policies/${FOLDER/.\//}"
#     cp $FILE ".policies/${FOLDER/.\//}"
# done

for FILE in $(find . -name "kyverno-test.yaml")
do
    FOLDER=$(dirname "$FILE")
    TARGET_FOLDER="$FOLDER/.kyverno-test"
    POLICY=$(basename "$FOLDER")
    POLICY_FILE="$POLICY.yaml"
    echo "$TARGET_FOLDER"
    rm -rf "$TARGET_FOLDER"
    mkdir -p $TARGET_FOLDER
    mv $FILE $TARGET_FOLDER
    for NEEDED in $(cat "$TARGET_FOLDER/kyverno-test.yaml" | grep -oE "(\w|-)+\.yaml")
    do
        if [[ $NEEDED == $POLICY_FILE ]]; then
            $SED -i "s@$POLICY_FILE@../$POLICY_FILE@" "$TARGET_FOLDER/kyverno-test.yaml"
        else
            mv "$FOLDER/$NEEDED" $TARGET_FOLDER || true
        fi
    done
done