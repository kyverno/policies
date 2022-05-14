# Kasten K10 by Veeam Data Protection Guardrails

## What are the Data Protection Guardrails (DPG)?
  
DPG is a set of K8s Native Data Protection Policies using Kyverno. DPG aims to **enforce** data protection of stateful cloud native applications from risks such as security incidents (ransomware), disasters (both natural and accidental), human error, and other incidents that would impact the availability of cloud native applications and services.  
  
DPG implements the [WG-Policy Management Whitepaper](https://github.com/kubernetes/community/blob/c61508a8651fcb49036188410becc36a3750217b/sig-security/policy/kubernetes-policy-management.md) in a data protection context.

## Why DPG?
Achieving data protection appears easy.  Let's “whip up” a daily cron job backup script and call it “production-ready.” 

However, battle-hardened IT experts will know that there are many additional risks to consider:
- The CIO's balance of cost and resources to implement a solution that reduces the acceptable data loss to minutes or hours.
- The GM's desire to limit financial impact due to downtime of a revenue generating app
- The CISO's requirement to have immutablity, a defense against ransomware operators who target destruction of backups.

Kasten K10's data protection guardrails protect stateful, cloud-native applications in a variety of ways:
- Backup RPO best practices (ie. hourly or daily enforcement)
- Checking K10 Location Profiles for immutability, a necessary defense against ransomware
- Overriding minimum retention policies in order to optimize storage costs or satisfy data retention compliance.
- Enable backup snapshots followed by exports to cloud object storage as part of "3-2-1"
- Assign data protection (by named K10 policies) to generate Kasten K10 Policy resources for self service data protection
