# Ephemeral Credentials Validator Policy

## Overview

This PR introduces a new Kyverno policy that enforces the use of ephemeral credentials with defined time-to-live (TTL) periods in Kubernetes. It addresses a critical security gap in the current policy collection by providing comprehensive credential lifecycle management rules.

## Problem Statement

Long-lived credentials in Kubernetes clusters represent a significant security risk:

1. **Permanent Attack Vectors**: Compromised credentials remain valid indefinitely
2. **Secret Sprawl**: Forgotten credentials accumulate over time
3. **No Rotation Enforcement**: Lack of mandatory credential rotation
4. **Incomplete Audit Trails**: No visibility into credential age or expiration

This policy helps organizations implement zero-trust security principles and comply with industry best practices for credential management.

## Implementation Details

The policy implements four complementary rules:

1. **Required TTL Annotations**: Enforces time-bound credentials
2. **Type-Based TTL Limits**: Implements different maximum lifetimes based on secret sensitivity
3. **Rotation Mechanism Validation**: Requires explicit rotation strategy declarations
4. **Expiration Reporting**: Generates reports for secrets nearing expiration

## Test Results

The policy has been tested with three representative scenarios:

1. **Fully Compliant Secret**: Passes all validation rules
   - Has TTL annotation: ✅
   - Has rotation mechanism annotation: ✅ 
   - TTL within allowed range: ✅

2. **Non-Compliant Secret**: Fails multiple validation rules
   - Has TTL annotation: ❌
   - Has rotation mechanism annotation: ❌

3. **Partially Compliant Secret**: Passes some but not all rules
   - Has TTL annotation: ✅
   - Has rotation mechanism annotation: ❌
   - TTL within allowed range: ❌ (90d exceeds 7d limit for Opaque secrets)

## Test Environment

Policy was tested using:
- Kyverno CLI testing framework
- Kyverno Policy Reporter for validation
- Multiple Kubernetes secret variations

## Compliance Benefits

This policy helps organizations:

- Implement NIST SP 800-63 recommendations for credential lifecycle
- Align with CIS Kubernetes Benchmarks for secret management
- Follow CNCF Security Technical Advisory Group recommendations
- Support Cloud Security Alliance security controls

## Integration Opportunities

The policy works well with existing secret management solutions:

- Seamless integration with External Secrets Operator
- Compatible with all major cloud secret managers
- Works with Sealed Secrets, HashiCorp Vault, and similar tools

## References

- [NIST Guidelines for Credential Management](https://pages.nist.gov/800-63-3/sp800-63b.html)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [CNCF Security Best Practices](https://github.com/cncf/tag-security) 