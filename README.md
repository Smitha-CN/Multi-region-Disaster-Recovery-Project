
Project2
Multi-Region Disaster Recovery Setup
Objective: To design and implement a multi-region disaster recovery solution using AWS services, where infrastructure is deployed in two AWS regions. The solution will replicate data across regions, ensure high availability, and implement a failover mechanism for disaster recovery. The project involves using Terraform to provision infrastructure, and CI/CD pipelines to ensure both regions remain synchronized for disaster recovery and failover.
Services used:
•	Amazon VPC : networking
•	Amazon S3 : For data replication across regions
•	Amazon RDS - for relational database deployment and cross-region replication
•	Amazon Route 53: for DNS failover routing
•	Terraform: for infrastructure provisioning
•	Jenkins: for CI/CD automation









Architectural Overview:

 
•	VPC - Provides isolated networking in both regions.
•	Amazon RDS - Primary in one region with cross-region read replica in the DR region. 
•	Amazon S3 - Cross-Region Replication (CRR) keeps data synchronized between regions.
•	Git - Repository and Terraform as IAC
•	Jenkins: For CI/CD
•	Route 53	Monitors RDS or app endpoints using health checks. Switches DNS to DR region on failure.
Step-by-Step Implementation Task
Step 1: Infrastructure Setup with Terraform
•	Create VPCs in Both Regions:
Provision VPCs in two AWS regions. Set up subnets, routing tables, and internet gateway for public subnet access.
•	Provision S3 Buckets for Data Replication:
o	Create S3 buckets in both regions
o	Create Iam role for s3 replication
o	Create policy to access cross region replication 
o	Create policy on source and destination bucket to give permission to replicate across region
o	 and enable Cross-Region Replication (CRR) to replicate data from Region 1 to Region 2.
•	Provision RDS Databases in Both Regions:
o	Set up an RDS instance in Region 1 (Primary) in one region
o	Secondary in Region 2 (Replica). 
o	Enabled cross-region replication using the arn of primary region to ensure data is synced between the primary and backup regions.
•	 Set up Route 53 Failover Routing:
o	Created 2 Ec2 Instances in 2 different region’
o	Created health checks for 2 ec2 instances using their public ip
o	Created hosted zones 
o	Setting up domain smithaproperties.com
o	Adding failover routing records as primary and secondary 
 Used Route 53 to configure DNS records with failover routing. The primary region will serve traffic, and the secondary region will act as a failover in case of failure.
•	Set up Terraform file 
o	 Give appropriate required providers
o	Select providers and set alias for 2 different regions
Step 2: CI/CD Pipeline Setup
•	Created Git repository
•	Committed terraform files
•	Installed and configured Jenkins for automating the deployment of resources.
•	Stored Aws credentials in manage Jenkins – credentials - store
•	manage Jenkins – credentials – store
•	Created the pipeline selecting SCM as git and branch as main where Jenkins file Is stored that is responsible for applying Terraform configurations to provision infrastructure and sync both regions.

 
 
 

Step 3: Monitoring and Alerts
•	Set up CloudWatch for Monitoring:
- Enable CloudWatch metrics and logs to monitor the health of S3 replication, 
•	Enabled Cloudwatch monitoring for RDS replication lad 
•	Enabled health checks for Ec2 instances that are used as primary and secondary in route 53
•	Added SNS topic to cloudwatch to trigger failures and successfully got email for replication lag in rds

 
 
 

Step 4: Testing and Validation
1.	Simulate Failover:
- Manually stoped the primary region ec2 instance  and verified that Route 53 correctly routes traffic to the secondary region.

2. Test Data Replication:
ensured that data stored in S3 Region 1 is correctly replicated to Region 2.   


Rds Replication verified in 2 regions database and table created in first database is replicated across replica database
  
3. Validate CI/CD Pipeline:
- Trigger the CI/CD pipeline to ensure both regions are in sync and that the deployment process is fully automated.
 
 
Conclusion:
•	Terraform configurations for provisioning VPCs, S3, RDS, and Route 53 failover routing.
•	Jenkins configuration for automating deployments and synchronization of regions.
•	Route 53 failover setup to ensure high availability and disaster recovery
•	CloudWatch configuration for monitoring replication status, health checks, and failure alerts




	




