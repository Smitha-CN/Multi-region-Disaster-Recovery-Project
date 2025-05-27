# Multi-Region AWS Disaster Recovery Setup

## 📌 Objective

Design and implement a **multi-region disaster recovery solution** using AWS services. The infrastructure is deployed in **two AWS regions**, replicating data and ensuring high availability via failover mechanisms. This solution uses **Terraform** for provisioning and **Jenkins** for CI/CD to keep both regions synchronized.

---

## 🧰 Technologies & Services Used

- **Amazon VPC** – Networking (public/private subnets)
- **Amazon S3** – Cross-Region Replication (CRR)
- **Amazon RDS** – Primary & cross-region read replica
- **Amazon Route 53** – DNS failover
- **Terraform** – Infrastructure as Code (IaC)
- **Jenkins** – CI/CD automation
- **AWS CloudWatch** – Monitoring and alerting
- **Git** – Version control

---

## 🏗️ Architecture Overview

- VPCs deployed in two AWS regions.
- S3 buckets with cross-region replication enabled.
- RDS primary instance in Region 1, read replica in Region 2.
- EC2 instances in both regions used for Route 53 failover health checks.
- Route 53 configured for DNS-based failover.
- CI/CD pipeline with Jenkins integrates Terraform to keep regions in sync.

---

## ⚙️ Step-by-Step Implementation

### Step 1: Infrastructure Setup with Terraform

- **VPC**: Create VPCs, subnets, route tables, internet gateways in both regions.
- **S3**:
  - Create buckets in both regions.
  - Setup IAM roles and policies for CRR.
  - Enable CRR from Region 1 to Region 2.
- **RDS**:
  - Deploy primary DB in Region 1.
  - Deploy read replica in Region 2 using cross-region replication.
- **EC2 & Route 53**:
  - Launch EC2 instances in both regions.
  - Configure health checks in Route 53.
  - Create hosted zone (`smithaproperties.com`) with failover routing.
- **Terraform**:
  - Use provider aliases for managing resources across multiple regions.
  - Define separate modules for reusable infrastructure components.

---

### Step 2: CI/CD Pipeline with Jenkins

- Initialize a Git repository and push all Terraform files.
- Configure Jenkins:
  - Install required plugins.
  - Store AWS credentials securely.
  - Setup pipeline job with Git SCM pointing to `main` branch.
  - Use `Jenkinsfile` to automate `terraform init`, `plan`, and `apply`.

---

### Step 3: Monitoring & Alerting

- Enable **CloudWatch metrics and logs**:
  - Monitor S3 CRR and RDS replication lag.
  - Track EC2 health used in Route 53 checks.
- Use **SNS topics** to send email alerts on failure or replication issues.

---

### Step 4: Testing and Validation

- ✅ **Simulate Failover**: Stopped EC2 in Region 1 and verified Route 53 switched traffic to Region 2.
- ✅ **S3 Replication**: Confirmed file replication from Region 1 to Region 2.
- ✅ **RDS Replication**: Verified table sync between primary and read replica.
- ✅ **CI/CD**: Triggered pipeline to ensure infrastructure is auto-provisioned in both regions.

---

## ✅ Conclusion

- Fully automated multi-region infrastructure with disaster recovery.
- High availability via Route 53 DNS failover.
- Automated provisioning and replication using Terraform and Jenkins.
- Real-time monitoring with CloudWatch and alerting via SNS.

---



