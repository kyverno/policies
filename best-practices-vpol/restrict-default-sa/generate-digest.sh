#!/bin/bash

# Generate SHA256 digest for artifacthub-pkg.yml
# Note: This should be run on a Linux system for consistency with Kyverno CI

echo "Generating SHA256 digest for restrict-default-sa.yaml..."
DIGEST=$(shasum -a 256 restrict-default-sa.yaml | awk '{print $1}')

echo "Digest: $DIGEST"
echo ""
echo "Updating artifacthub-pkg.yml..."

# Update the artifacthub-pkg.yml with the actual digest
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/PLACEHOLDER_DIGEST_TO_BE_GENERATED_ON_LINUX/$DIGEST/" artifacthub-pkg.yml
else
  # Linux
  sed -i "s/PLACEHOLDER_DIGEST_TO_BE_GENERATED_ON_LINUX/$DIGEST/" artifacthub-pkg.yml
fi

echo "✅ Digest updated in artifacthub-pkg.yml"
echo ""
echo "⚠️  NOTE: If you're on macOS, you should regenerate this digest on a Linux system"
echo "    before submitting your PR, as the Kyverno CI expects Linux-generated digests."
echo ""
echo "    On Linux, run:"
echo "    sha256sum restrict-default-sa.yaml | awk '{print \$1}'"
