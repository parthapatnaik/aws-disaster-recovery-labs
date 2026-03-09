# AWS Disaster Recovery Labs
A hands-on AWS project to demonstrate the **four major Disaster Recovery (DR) strategies** using:
- Manual implementation steps
- Terraform Infrastructure as Code
- DR testing scenarios
- Architecture diagrams
- Real AWS screenshots

## DR Strategies Covered
1. Backup & Restore  
2. Pilot Light  
3. Warm Standby  
4. Active-Active (Multi-Region)

## Why this project?
One of the biggest misconceptions in cloud architecture is:

**“If my application is Multi-AZ, I already have Disaster Recovery.”**
That is not always true.

Multi-AZ helps improve availability **within a single AWS Region**.  
Disaster Recovery is about how systems recover when there is a **larger failure**, such as:
- Regional outage
- Major infrastructure issue
- Data corruption
- Application failure
- Operational mistake

This repository is being built to show how AWS DR strategies are designed, implemented, and tested in real-world environments.

## What this repository will include
- Simple explanation of each DR strategy
- RTO / RPO discussion
- Manual AWS setup steps
- Terraform code
- Live DR test scenarios
- Architecture diagrams
- Real screenshots from implementation

## DR Strategy Comparison
| Strategy | Cost | Recovery Speed | Complexity | Best For |
|----------|------|----------------|------------|----------|
| Backup & Restore | Low | Slow | Low | Non-critical applications |
| Pilot Light | Medium | Faster than Backup & Restore | Medium | Important applications |
| Warm Standby | Medium to High | Fast | Medium to High | Business-critical workloads |
| Active-Active | High | Very Fast | High | Mission-critical customer-facing systems |

## Learning Goal
The goal of this project is to understand:
- how each DR strategy works
- when each strategy should be used
- how business RTO/RPO requirements affect architecture decisions
- how DR should be tested, not just documented

## Who this project is for
This repository is useful for:
- Cloud Architects
- DevOps Engineers
- SREs
- AWS learners
- Students preparing for interviews
- Teams designing resilient cloud systems

## Author

**Partha Patnaik**  
Principal Cloud Architect | AWS | Distributed Systems | Cloud Resilience
