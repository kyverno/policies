# Ephemeral Credentials Validator

This Kyverno policy enforces the use of ephemeral credentials with defined time-to-live (TTL) periods in Kubernetes. It helps organizations implement credential lifecycle management and reduce the security risks associated with long-lived credentials.

## Why Ephemeral Credentials Matter

Long-lived credentials pose significant security risks:
- They become forgotten but remain valid, creating security blind spots
- When compromised, they provide extended access to attackers
- They lack audit trails for renewal and review
- They violate least-privilege principles of zero-trust security models

This policy enforces ephemeral credentials practices that are recommended by:
- NIST Digital Identity Guidelines (SP 800-63)
- CIS Kubernetes Benchmarks
- CNCF Security Technical Advisory Group
- Cloud Security Alliance Guidelines

## Policy Features

The Ephemeral Credentials Validator enforces four key rules:

### 1. Required TTL Annotations

All secrets must include a `secrets.kubernetes.io/ttl` annotation specifying their intended lifetime, for example:

```yaml
metadata:
  annotations:
    secrets.kubernetes.io/ttl: "72h"  # 72 hours
```

### 2. Maximum TTL Based on Sensitivity

Different types of secrets have different maximum allowed TTLs based on sensitivity:

| Secret Type | Maximum TTL | Example Use Case |
|-------------|-------------|-----------------|
| kubernetes.io/service-account-token | 24h | Service account tokens |
| kubernetes.io/dockerconfigjson | 30d | Registry credentials |
| kubernetes.io/tls | 90d | TLS certificates |
| Opaque | 7d | Application secrets |

### 3. Required Rotation Mechanism

All secrets must specify their rotation mechanism via the `secrets.kubernetes.io/rotation-mechanism` annotation, for example:

```yaml
metadata:
  annotations:
    secrets.kubernetes.io/rotation-mechanism: "external-secrets-operator"
```

Valid values include:
- `external-secrets-operator`
- `sealed-secrets-rotation`
- `vault-agent`
- `aws-secrets-manager`
- `azure-key-vault`
- `gcp-secret-manager`
- `manual`

### 4. Expiry Reporting

The policy generates reports for secrets nearing expiration (within 7 days) to provide visibility into required rotation activities.

## Installation

Apply the policy to your cluster:

```bash
kubectl apply -f ephemeral-credentials-validator.yaml
```

## Integration Partners

This policy works well with external secret management systems:

- External Secrets Operator
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault
- Google Secret Manager
- Sealed Secrets

## Example Usage

### Compliant Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: compliant-secret
  annotations:
    secrets.kubernetes.io/ttl: "24h"
    secrets.kubernetes.io/rotation-mechanism: "external-secrets-operator"
type: Opaque
data:
  username: YWRtaW4=
  password: cGFzc3dvcmQ=
```

### Non-Compliant Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: non-compliant-secret
  # Missing TTL annotation
  # Missing rotation mechanism annotation
type: Opaque
data:
  username: YWRtaW4=
  password: cGFzc3dvcmQ=
```

## Customization

Organizations can customize this policy by:

1. Adjusting TTL values based on risk tolerance
2. Adding additional secret types with appropriate TTLs
3. Modifying the reporting window for expiring secrets
4. Adding organization-specific rotation mechanisms

## Limitations

- Service account tokens managed by Kubernetes automatically are excluded
- System namespace secrets (kube-system, kube-public, kube-node-lease) are excluded
- The policy assumes annotations are correctly applied at secret creation

## Related Best Practices

- Use externalized secret management systems
- Implement automated rotation mechanisms
- Apply least-privilege principles to service accounts
- Use certificate lifecycle management for TLS secrets 