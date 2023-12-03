#!/usr/bin/env bash

set -euo pipefail

SED=sed

if [[ "$OSTYPE" == "darwin"* ]]; then
    SED=gsed
fi

for FILE in $(find . -name "artifacthub-pkg.yml")
do
    FOLDER=$(dirname "$FILE")
    POLICY=$(basename "$FOLDER")
    POLICY_FILE="$FOLDER/$POLICY.yaml"
    echo "Processing policy $POLICY ($POLICY_FILE) ..."
    INSTALL="kubectl apply -f https://raw.githubusercontent.com/kyverno/policies/main/${POLICY_FILE/.\//}"
    $SED -i -z "s#install:.*\`\`\`#install: |-\n  \`\`\`shell\n  $INSTALL\n  \`\`\`#" $FILE
    DIGEST=$(shasum -U -a 256 "$POLICY_FILE" | cut -d" " -f 1)
    echo "  Digest: $DIGEST"
    $SED -i "s/^digest:.*/digest: $DIGEST/" $FILE
    if ! grep -q "createdAt:" "$FILE"; then
        NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "createdAt: \"${NOW}\"" >> $FILE
    fi
done
