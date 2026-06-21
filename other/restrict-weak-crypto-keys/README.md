# Restrict Weak Crypto Keys

## Description

RSA keys smaller than 3072 bits are considered weak by NIST SP 800-131A and provide insufficient security margins against both classical and quantum computing attacks. CNSA 2.0 guidance recommends RSA-3072 as the minimum for near-term use while transitioning to post-quantum cryptography (PQC) algorithms.

This Kyverno ClusterPolicy blocks the creation of TLS Secrets containing RSA keys with fewer than 3072 bits, enforcing a minimum key strength for quantum-preparedness.

## Policy Details

| Field | Value |
|---|---|
| **Category** | Security |
| **Severity** | High |
| **Mode** | Enforce (blocks resource creation) |
| **Subject** | Secret |
| **Min Kyverno Version** | 1.10.0 |
| **Kubernetes Version** | 1.27+ |

## Install

```shell
kubectl apply -f https://raw.githubusercontent.com/kyverno/policies/main/other/restrict-weak-crypto-keys/restrict-weak-crypto-keys.yaml
```

## How It Works

1. Matches all Secrets of type `kubernetes.io/tls` on CREATE or UPDATE operations.
2. Decodes the `tls.crt` field using `base64_decode` and parses it with `x509_decode`.
3. Checks if the `PublicKeyAlgorithm` is RSA and if the key size is less than 3072 bits.
4. Blocks the Secret creation if both conditions are met.

## Background

- **NIST SP 800-131A**: Specifies RSA-2048 as minimum but recommends RSA-3072 for data protection beyond 2030.
- **CNSA 2.0**: NSA guidance requires RSA-3072 minimum for near-term use during PQC transition.
- **Quantum Risk**: While RSA-2048 may still resist classical attacks, the security margin against future quantum computers is insufficient. RSA-3072 provides approximately 128-bit security equivalent, the minimum recommended for post-2030 protection.
