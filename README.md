# aws-disaster-recovery-labs
Hands-on AWS Disaster Recovery labs covering Backup &amp; Restore, Pilot Light, Warm Standby, and Active-Active strategies using manual steps, Terraform, and DR testing.

# AWS Disaster Recovery Labs

A hands-on architecture repository to demonstrate the four major AWS Disaster Recovery strategies using:

- Manual implementation steps
- Terraform Infrastructure as Code
- DR validation and failover testing
- Architecture diagrams
- Real AWS screenshots

## Strategies Covered

1. Backup & Restore
2. Pilot Light
3. Warm Standby
4. Active-Active (Multi-Region)

## DR Strategy Comparison

| Strategy | Cost | Complexity | RTO | RPO | Best For |
|----------|------|------------|-----|-----|----------|
| Backup & Restore | Low | Low | High | Medium to High | Non-critical applications |
| Pilot Light | Medium | Medium | Medium | Medium | Important apps with moderate DR requirements |
| Warm Standby | Medium to High | Medium to High | Low | Low | Business-critical workloads |
| Active-Active | High | High | Very Low | Very Low | Mission-critical customer-facing systems |

## Why this project?

## Why this repository matters

Disaster Recovery is often discussed in theory, but many teams never test how recovery actually works in practice.

This repository is intended to bridge that gap by showing:
- how each DR strategy maps to business expectations
- how RTO and RPO affect architecture decisions
- how AWS services are used differently across strategies
- how recovery should be validated through live testing, not only documentation

This project is also part of a broader architecture knowledge-sharing journey, where real-world scenarios, design trade-offs, and implementation patterns will be published for the community.

## What this repository will include

- Business explanation of each strategy
- RTO / RPO discussion
- Architecture diagrams
- Manual implementation steps
- Terraform code
- Live DR test scenarios
- Screenshots from actual implementation

## Author

Partha Patnaik  
Principal Cloud Architect | AWS | Distributed Systems | Cloud Resilience
