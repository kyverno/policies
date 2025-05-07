# Validate Container Image SBOM

This policy enforces that container images deployed in a Kubernetes cluster have associated Software Bills of Materials (SBOMs) that meet government and industry standards for supply chain security.

## Policy Details

The policy performs the following validations:

1. **SBOM Existence**: Ensures each container has an SBOM referenced via annotations
2. **SBOM Format**: Validates the SBOM is in a proper format (CycloneDX or SPDX) and accessible via URL or data URI
3. **SBOM Signature**: Ensures the SBOM has a valid signature from an approved authority
4. **SBOM Completeness**: Verifies the SBOM contains all required components to meet government standards

## Background

Software Bills of Materials (SBOMs) are increasingly important for security and compliance:

- Executive Order 14028 requires SBOMs for federal software procurement
- NIST SSDF (Secure Software Development Framework) recommends SBOMs for supply chain security
- CISA guidance on securing the software supply chain emphasizes SBOM implementation
- Zero-trust architectures rely on verifiable software components

## Annotation Format

This policy expects the following annotation pattern:

```yaml
security.kyverno.io/container-sbom-<container-name>: "URL or reference to SBOM"
security.kyverno.io/container-sbom-signature-<container-name>: "URL or reference to signature"
security.kyverno.io/container-sbom-completeness-<container-name>: "verified"
```

## Example

A Pod with valid SBOM annotations:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-valid-sbom
  annotations:
    security.kyverno.io/container-sbom-nginx: "https://example.com/sboms/cyclonedx-nginx.json"
    security.kyverno.io/container-sbom-signature-nginx: "https://example.com/sboms/cyclonedx-nginx.json.sig"
    security.kyverno.io/container-sbom-completeness-nginx: "verified"
spec:
  containers:
  - name: nginx
    image: nginx:1.21.6
    ports:
    - containerPort: 80
```

## How to Use

To apply this policy to your cluster:

```bash
kubectl apply -f https://raw.githubusercontent.com/kyverno/policies/main/supply-chain-security/validate-container-sbom/validate-container-sbom.yaml
```

## Recommendations

Organizations should establish processes to:

1. Generate SBOMs for all container images during build
2. Sign SBOMs using established PKI infrastructure
3. Verify and validate SBOM completeness against requirements
4. Store SBOMs in accessible repositories or registries 