#!/bin/bash

set -e

echo -e "\nDownloading the latest Kyverno installation YAML file..."
wget -O install-latest-testing.yaml https://github.com/kyverno/kyverno/raw/main/config/install-latest-testing.yaml

echo -e "\nEnabling Validating Admission Policy generation..."
sed -i 's/--generateValidatingAdmissionPolicy=false/--generateValidatingAdmissionPolicy=true/g' ./install-latest-testing.yaml

echo -e "\nInstalling Kyverno in the cluster..."
kubectl create -f ./install-latest-testing.yaml

echo -e "\nGranting permissions to Kyverno for VAP generation..."
kubectl create -f ./.github/scripts/config/generate-validating-admission-policy/generate-vap-cr.yaml
