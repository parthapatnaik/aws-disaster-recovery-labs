# Backup & Restore Strategy

## Overview
Backup & Restore is the **simplest and lowest-cost disaster recovery strategy**.

In this model:
- The application runs in a **primary AWS region**
- Backups of servers and databases are taken regularly
- Backups are stored safely (for example in Amazon S3)
- If a disaster happens, the infrastructure is restored in another region

This approach is commonly used when the business can tolerate **longer recovery time**.
---

## Example Architecture
Primary Region: Mumbai (ap-south-1)
Resources:
- EC2 application server
- RDS database
- S3 backups
- AMI snapshots

Disaster Recovery Region:
- Singapore (ap-southeast-1)

In case of disaster:
- restore AMI
- restore database snapshot
- launch new infrastructure

---
## RTO and RPO
| Metric | Expected |
|------|------|
| RTO (Recovery Time Objective) | High (minutes to hours) |
| RPO (Recovery Point Objective) | Medium (depends on backup frequency) |
---

## When this strategy is used
Backup & Restore is suitable for:
- internal tools
- dev/test systems
- small applications
- workloads with limited DR budget
---

## What this lab will demonstrate
This lab will show:
1. Deploy application in primary region
2. Create backups
3. Store backups safely
4. Simulate disaster
5. Restore infrastructure in DR region
---

## AWS Services Used
- Amazon EC2
- Amazon RDS
- Amazon S3
- EBS Snapshots
- AMI
- Route 53 (optional)
---

## Next Steps
Upcoming updates will include:
- Manual implementation steps
- Terraform deployment
- Disaster recovery testing
- Screenshots of the process
