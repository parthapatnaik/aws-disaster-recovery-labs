# Backup & Restore – AWS Disaster Recovery Strategy

## Overview
Backup & Restore is the **simplest and lowest-cost Disaster Recovery (DR) strategy**.

In this approach:
- The application runs in a **primary AWS region**
- Backups of servers and databases are taken regularly
- Backups are stored securely (typically in Amazon S3)
- In the event of a disaster, infrastructure is **recreated in a secondary region using the backups**

This strategy is commonly used when the business can tolerate **longer recovery times** and when minimizing infrastructure cost is important.

---

## Example Architecture
Primary Region: **Mumbai (ap-south-1)**

Resources running:
- EC2 Application Server
- RDS Database
- EBS Volumes
- S3 Backup Storage

Backups created:
- EC2 AMI snapshots
- RDS snapshots
- EBS snapshots
- Application backups stored in S3

Disaster Recovery Region: **Singapore (ap-southeast-1)**
During a disaster:
1. Launch EC2 instances from AMI backup
2. Restore RDS from snapshot
3. Reconfigure networking and security groups
4. Update DNS (Route 53) to point to DR region

---

## RTO and RPO
| Metric | Description |
|------|------|
| **RTO (Recovery Time Objective)** | High (minutes to hours depending on restore time) |
| **RPO (Recovery Point Objective)** | Medium (depends on backup frequency) |

Example:
If backups are taken every **6 hours**, the potential data loss could be **up to 6 hours**.

---
## When This Strategy Is Used
Backup & Restore is suitable for:
- Internal tools
- Development environments
- Non-critical applications
- Cost-sensitive workloads
- Applications where longer downtime is acceptable

---
## AWS Services Used
Typical AWS services involved:

- **Amazon EC2** – Application servers
- **Amazon RDS** – Database
- **Amazon S3** – Backup storage
- **EBS Snapshots** – Disk backups
- **AMI** – EC2 machine images
- **Route 53** – DNS failover (optional)

---
## Lab Implementation Plan
This lab will demonstrate:
1. Deploy a simple application in **Primary Region**
2. Create backups of EC2 and database
3. Store backups securely
4. Simulate a disaster scenario
5. Restore infrastructure in the **DR Region**
6. Validate application recovery

---
## DR Testing Scenario
Disaster Recovery plans must always be **tested**.

Example test for this lab:
### Scenario: Primary Region Failure

Steps:
1. Stop the EC2 instance in the primary region
2. Assume region failure
3. Restore EC2 using AMI in DR region
4. Restore database from snapshot
5. Update Route 53 to point to DR environment
6. Verify application accessibility

Expected Result:
Application becomes available from **DR region** after restoration.

---
## Key Learning Outcomes
After completing this lab you will understand:
- How Backup & Restore DR works in AWS
- How RTO and RPO affect DR strategy selection
- How backups are used to rebuild infrastructure
- Why DR testing is critical for production systems

---
## Next Labs in This Repository

This project will also include:

- **Pilot Light Strategy**
- **Warm Standby Strategy**
- **Active-Active**
- **Active-Active Multi-Region Architecture**

Each lab will demonstrate the **architecture, setup steps, and DR testing scenarios**.
