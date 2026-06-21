# Audit Certificate Key Algorithms

## Description

Classical cryptographic key algorithms such as RSA and ECDSA are vulnerable to quantum computing attacks. Organizations preparing for post-quantum cryptography (PQC) migration need visibility into which TLS certificates use quantum-vulnerable key algorithms.

This Kyverno ClusterPolicy audits Secrets of type `kubernetes.io/tls` and reports findings via PolicyReport when certificates use RSA, ECDSA, or DSA key algorithms. It uses the `x509_decode` function to parse the certificate and inspect the `PublicKeyAlgorithm` field.

## Policy Details

| Field | Value |
|---|---|
| **Category** | Security |
| **Severity** | Medium |
| **Mode** | Audit (generates PolicyReport, does not block) |
| **Subject** | Secret |
| **Min Kyverno Version** | 1.10.0 |
| **Kubernetes Version** | 1.27+ |

## Install

```shell
kubectl apply -f https://raw.githubusercontent.com/kyverno/policies/main/other/audit-certificate-key-algorithms/audit-certificate-key-algorithms.yaml
```

## How It Works

1. Matches all Secrets of type `kubernetes.io/tls` on CREATE or UPDATE operations.
2. Decodes the `tls.crt` field using `base64_decode` and parses it with `x509_decode`.
3. Checks the `PublicKeyAlgorithm` field against a list of quantum-vulnerable algorithms (RSA, ECDSA, DSA).
4. Generates a PolicyReport finding for any certificate using a vulnerable algorithm.

## Background

- **Shor's Algorithm**: A sufficiently powerful quantum computer running Shor's algorithm can break RSA and ECC in polynomial time.
- **NIST PQC Standards**: ML-DSA (Dilithium) is the NIST-standardized post-quantum digital signature algorithm intended to replace RSA and ECDSA.
- **Migration Planning**: This audit policy provides the inventory needed to plan certificate migration to PQC algorithms.
