# AutoFinOps: Real-Time Cloud Cost Optimization Platform for SaaS (AWS)

> Cut cloud waste by **30–40%**, reducing monthly spend from **₹50L to ~₹30L**, saving **₹1–₹1.5 crore annually** while improving **cost visibility** and **operational efficiency**.

# Business Problem
A mid-sized SaaS company on Amazon Web Services spends **₹35–₹50 lakhs monthly**, with **25–40% wasted** due to idle compute, over-provisioned databases, and unused storage. Despite **predictable workloads**, the **lack of real-time cost visibility** and **automated optimization** leads to consistent **over-provisioning** and **billing spikes**. A **small DevOps team**, without a **dedicated FinOps practice**, cannot efficiently manage optimization across **50+ services** without risking reliability. If unresolved, this could result in **₹1–₹1.5 crore in annual losses**, directly impacting **profitability** and limiting **future growth**.

# Solution Overview & Architecture
This project solves business problem that mentioned above by implementing an Automated AWS FinOps platform using Terraform and Serverless AWS Services.

### The system continuously monitors :
- EC2 CPU utilization and network in
- RDS Connections and instance CPU utilization
- S3 Bucket usage and storage

### If resource usage remains below defined thresholds for a configurable duration :
- automated actions are triggered
- unused resources are stopped 
- notifications are sent to administrators

### The infrastructure was designed using:
- Lambda Automation
- EventBridge Schedules
- CloudWatch Alarms
- IAM least-privilege policies
- Terraform modular infrastructure 

This architecture minimizes manual monitoring while maintining secure and scalable operations.

# Architecture Diagram
![FinOps Architecture Diagram](https://raw.githubusercontent.com/Swapni-1/AWS-Real-World-Problem-Solving-Projects/refs/heads/main/Project%201/assets/FinOps%20Architecture%20Diagram.jpg)

# Key Architecture Decisions & Trade-offs

| Decision | Chosen Option | Why This Over Alternative | Trade-off / Risk Mitigated |
|----------|---------------|---------------------------|----------------------------|
| Compute Automation | AWS Lambda | | |
| Scheduling | Event-Bridge Scheduler | | |
| Scheduling Auto-Scaling Groups | Auto-Scaling  Schedule | | |
| Monitoring | CloudWatch Custom Dashboard | | |
| Handling Unpredictable Traffic Spike | Auto-Scaling Groups | | |
| Storage Optimization | S3 Bucket | | | 
| Database Optimization | RDS | | |
| Networking | VPC | | |
| Security | IAM | | |
| Alert Messaging | SNS | | | 

Write 1–2 sentences explaining **your thinking** for each row. This proves depth.

## Core AWS Services Used (Only 4–6 max)
- **Lambda** - Short 1-line purpose + why it was perfect
- **Event-Scheduler** -
- **CloudWatch** -
- **Auto-Scaling** -
- **SNS** -

Never list 20 services. Show focus.

## Infrastructure as Code – 100% Terraform
- “Everything is defined as code. No ClickOps was used in production setup.”
- Key highlights:
  - Modular structure (show folder tree)
  - `terraform apply` deploys the entire environment in < 3 minutes
  - Variables, outputs, and state management explained
  - How you would recreate the exact environment in another region/AZ

## Folder Structure
```bash
.
└── aws-finops-simulation/
    ├── environments/
    │   └── dev/
    │       ├── .terraform
    │       ├── .terraform.lock.hcl
    │       ├── backend.tf
    │       ├── main.tf
    │       ├── provider.tf
    │       ├── terraform.tf
    │       ├── terraform.tfstate
    │       ├── terraform.tfstate.backup
    │       ├── terraform.tfvars
    │       └── variables.tf
    └── modules/
        ├── cloudwatch/
        │   ├── alarms.tf
        │   ├── data.tf
        │   ├── main.tf
        │   ├── outputs.tf
        │   ├── scheduler.tf
        │   └── variables.tf
        ├── auto-scaling/
        │   ├── scripts/
        │   │   ├── web-server-setup.sh
        │   │   └── web-server-stress-test-setup.sh
        │   ├── data.tf
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── lambda/
        │   ├── functions/
        │   │   ├── rds_optimizer.py
        │   │   ├── rds_scheduler_start.py
        │   │   ├── rds_scheduler_stop.py
        │   │   └── s3_optimizer.py
        │   ├── data.tf
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── rds/
        │   ├── data.tf
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── s3/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── security-group/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── sns/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── vpc/
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```

## Fundamentals Demonstrated
(Proves you didn’t skip basics – Sleman’s mistake #2)

- **Networking**: Explanation of VPC CIDR, public vs private subnets, why you chose them, security group rules, route tables.
- **Security**: Least-privilege IAM roles (no access keys), encryption at rest/transit, bucket policies.
- **Linux / OS**: User-data scripts, logging, SSH hardening (if EC2 used).
- **High Availability & Scaling**: Multi-AZ, auto-scaling policies, health checks.
- **Cost Optimization**: How you kept monthly cost under ₹800–1500 even at peak.

## Deployment Instructions (One-Command Deploy)
```bash
git clone <repo>
cd project
terraform init
terraform apply -auto-approve
```

## Prerequisites

## Configuration / Variables

## Validation & Testing

## Business Impact & Results

## Cost Optimization Notes (Free-Tier / Low-Cost)

## Monitoring & Operations

## Troubleshooting / Incident Recovery Guide

## Lessons Learned & What I Would Change

# Engineering Mindset & Problem Solving Approach
Several Components in this project were unfamiliar initially, including:
- Terraform state management
- VPC CIDR block (public and private subnets)
- Security Groups (restricted inbound rules)
- User data script debugging
- Auto Scaling Groups and it's policy and schedule
- Application Load Balancer and it's main components
- AWS SSM Parameter Store (SecureString) 
- S3 Bucket (storage encryption using SSE)
- CloudWatch (metrices, widgets, alarm, custom dashboard)
- EventBridge (rules, targets, schedule)
- AWS Lambda function (execution and code debugging)
- IAM (roles and policies) and role debugging
- Event-driven automation
- Cost Optimization technique
- Tagging strategy

Approach used :


# Future Enhancements

# Screenshots / Live Demo

# Clean-Up / Destroy Infrastructure
```bash
terraform destroy -auto-approve
```
important :
- Empty S3 bucket before destroy
- Verify billing dashboard after cleanup
---
# Security Considerations
Security measures implemented:
- least-privilage IAM access
- encrypted storage
- private subnets
- security groups (restricted inbound rules)
- no public database access
- restriction on public S3 bucket access

# AI Usage Note
AI tools such as ChatGPT and Claude were used only for initial idea exploration and Terraform draft assistance.

All infrastructure decisions, debugging, architecture design, testing and implementation were manually reviewed and validated before deployment.

# Author

Swapnil Lakra

Cloud Engineer  
Focused on AWS, Terraform, FinOps, and scalable infrastructure automation.


