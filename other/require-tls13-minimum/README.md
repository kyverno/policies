# Require TLS 1.3 Minimum

## Description

TLS 1.3 is a prerequisite for post-quantum cryptography (PQC) key exchange mechanisms such as ML-KEM (Kyber). Older TLS versions (1.0, 1.1, 1.2) do not support the hybrid key exchange groups required for quantum-safe communication.

This Kyverno ClusterPolicy audits Ingress resources to ensure they enforce TLS 1.3 as the minimum protocol version. It performs two checks:

1. **TLS annotation check** -- Validates that the `nginx.ingress.kubernetes.io/ssl-min-protocol` annotation is set to `TLSv1.3`.
2. **TLS section check** -- Validates that `spec.tls` is defined on the Ingress resource.

## Policy Details

| Field | Value |
|---|---|
| **Category** | Security |
| **Severity** | High |
| **Mode** | Audit (generates PolicyReport, does not block) |
| **Subject** | Ingress |
| **Min Kyverno Version** | 1.6.0 |
| **Kubernetes Version** | 1.27+ |

## Install

```shell
kubectl apply -f https://raw.githubusercontent.com/kyverno/policies/main/other/require-tls13-minimum/require-tls13-minimum.yaml
```

## Background

- **NIST PQC**: Post-quantum key exchange (ML-KEM/Kyber) requires TLS 1.3 as the transport layer.
- **CNSA 2.0**: NSA's Commercial National Security Algorithm Suite 2.0 mandates TLS 1.3 for quantum-resistant communication.
- **RFC 8446**: TLS 1.3 removes support for vulnerable legacy features and provides the extensibility needed for PQC hybrid key exchange.
