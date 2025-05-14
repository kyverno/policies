# Validate Container SBOM Policy

This policy validates that container images have associated Software Bills of Materials (SBOMs) that meet government and industry standards. It helps organizations comply with Executive Order 14028, NIST SSDF, and CISA guidance on securing the software supply chain.

## Policy Details

The policy performs four key validations:

1. **SBOM Existence**: Ensures each container has an associated SBOM referenced by annotation
2. **Format Validation**: Verifies SBOM is in CycloneDX or SPDX format with proper URL
3. **Signature Verification**: Checks that SBOM is signed by a trusted authority
4. **Completeness Check**: Validates SBOM meets minimum completeness requirements

## SBOM Annotations

The policy uses Kubernetes annotations to reference SBOMs, following established patterns used by tools like Cosign, Notary v2, and Google's Binary Authorization. This approach provides:

- **Flexibility**: Supports multiple SBOM storage methods:
  - HTTPS URLs (artifact servers)
  - OCI registry references
  - Cosign transparency log
  - Direct data URLs
- **Integration**: Works with existing container scanning and signing tools
- **Kubernetes-Native**: Uses standard Kubernetes metadata mechanisms

Required annotations per container:
```yaml
security.kyverno.io/container-sbom-{container-name}: "https://example.com/sboms/cyclonedx.json"
security.kyverno.io/container-sbom-signature-{container-name}: "https://example.com/sboms/cyclonedx.json.sig"
security.kyverno.io/container-sbom-completeness-{container-name}: "verified"
```

## File Structure

- `validate-container-sbom.yaml`: Main ClusterPolicy definition
- `validate-container-sbom-report.yaml`: PolicyReport showing validation results
- `test/`: Test resources
  - `resources.yaml`: Sample Pods for testing (valid, invalid, missing SBOM)
  - `.kyverno-test/`: Kyverno CLI test configurations
  - `.chainsaw-test/`: Chainsaw test configurations

## Usage

1. Apply the policy:
```bash
kubectl apply -f validate-container-sbom.yaml
```

2. The policy runs in audit mode by default. Monitor violations:
```bash
kubectl get policyreport validate-container-sbom-results -o yaml
```

## Testing

Run tests using either Kyverno CLI or Chainsaw:

```bash
# Kyverno CLI
kyverno test .kyverno-test/

# Chainsaw
chainsaw test .chainsaw-test/
```

## Background

Software Bills of Materials (SBOMs) are increasingly important for security and compliance:

- Executive Order 14028 requires SBOMs for federal software procurement
- NIST SSDF (Secure Software Development Framework) recommends SBOMs for supply chain security
- CISA guidance on securing the software supply chain emphasizes SBOM implementation
- Zero-trust architectures rely on verifiable software components

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

## Recommendations

Organizations should establish processes to:

1. Generate SBOMs for all container images during build
2. Sign SBOMs using established PKI infrastructure
3. Verify and validate SBOM completeness against requirements
4. Store SBOMs in accessible repositories or registries 