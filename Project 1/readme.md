
# AutoFinOps – Real-Time AWS Cloud Cost Optimization Platform

> The system is designed to reduce simulated SaaS cloud waste by 30–40% using automated infrastructure optimization, centralized monitoring, and event-driven AWS workflows.

---

## Table of Contents

- [Business Problem](#business-problem)
- [Solution Overview](#solution-overview)
- [Architecture Diagram](#architecture-diagram)
- [Key Features](#key-features)
- [Key Architecture Decisions & Trade-offs](#key-architecture-decisions--trade-offs)
- [Fundamentals Demonstrated](#fundamentals-demonstrated)
- [AWS Services Used](#aws-services-used)
- [Business Impact & Results](#business-impact--results)
- [Deployment](#deployment)
- [Cost Optimization Techniques](#cost-optimization-techniques)
- [Lessons Learned](#lessons-learned)
- [Future Improvements](#future-improvements)
- [Security Considerations](#security-considerations)
- [AI Usage Note](#ai-usage-note)

---

# Business Problem

A mid-sized SaaS company operating on AWS was experiencing rapidly increasing cloud infrastructure costs caused by idle compute resources, overprovisioned databases, and limited visibility into infrastructure utilization patterns.

Although workload traffic remained relatively predictable, the organization lacked centralized monitoring, automated optimization workflows, and a dedicated FinOps practice. A small DevOps team managing multiple AWS services could not efficiently identify and optimize underutilized infrastructure without introducing operational risk or additional management overhead.

If left unresolved, the company risked wasting 25–40% of its monthly AWS spending, potentially resulting in ₹1–₹1.5 crore in annual infrastructure losses.

The objective was to design a low-cost, event-driven optimization platform capable of improving infrastructure efficiency while maintaining scalability, security, and operational reliability.

---

# Solution Overview

This project implements an automated FinOps optimization platform using Terraform and native AWS services.

The architecture was designed to:
- monitor EC2 and RDS utilization patterns
- identify underutilized infrastructure
- automate optimization workflows
- improve infrastructure visibility through centralized monitoring

Automation workflows were implemented using:
- AWS Lambda
- Amazon EventBridge
- Amazon CloudWatch
- Amazon SNS

Infrastructure provisioning and configuration management were handled entirely through Terraform using a modular Infrastructure as Code approach.

The overall design prioritizes:
- operational simplicity
- low-cost automation
- infrastructure visibility
- scalable event-driven workflows

---

# Architecture Diagram

![Architecture Diagram](https://raw.githubusercontent.com/swapnil-lakra/AWS-Real-World-Problem-Solving-Projects/109581ae5c7ff762044e7a7f60655f4d36a368fe/Project%201/diagrams/FinOps%20Architecture%20Diagram.svg)

The infrastructure is deployed inside a secure Amazon VPC using both public and private subnets to simulate a realistic mid-sized SaaS environment.

Incoming traffic reaches the EC2 instances running inside an Auto Scaling Group (ASG) deployed across private subnets within the VPC. The architecture was designed to improve scalability and infrastructure isolation while limiting unnecessary public exposure to backend services and the database layer.

The application servers communicate with an Amazon RDS MySQL database hosted securely in private subnets. Access to Amazon S3 is handled through an S3 Gateway Endpoint, allowing private connectivity without exposing traffic to the public internet.

The application servers communicate with an Amazon RDS MySQL database hosted securely in private subnets. Access to Amazon S3 is handled through an S3 Gateway Endpoint, allowing private connectivity without exposing traffic to the public internet.

Infrastructure metrics such as CPU utilization, database connections, scaling activity, and storage usage are continuously collected through Amazon CloudWatch. Centralized dashboards and alarms provide visibility into infrastructure health and utilization patterns.

When predefined conditions are met — such as low database activity or idle infrastructure — CloudWatch triggers event-driven workflows using Amazon EventBridge and AWS Lambda. Amazon SNS is used to deliver infrastructure alerts and optimization notifications.

To reduce unnecessary cloud spending, the platform implements automated FinOps optimization workflows. The RDS database automatically starts and stops based on business-hour schedules, while additional automation identifies prolonged idle conditions and shuts down underutilized resources when appropriate. Scheduled Auto Scaling actions further reduce unnecessary compute runtime during low-traffic periods.

All networking, compute, monitoring, automation, and security components are provisioned using Terraform with a modular Infrastructure as Code approach to support repeatable, maintainable, and environment-consistent deployments.

## Infrastructure Monitoring

Centralized CloudWatch dashboards provide visibility into EC2 utilization, RDS activity, scaling behavior, and infrastructure health metrics.

![CloudWatch Dashboard](https://github.com/swapnil-lakra/AWS-Real-World-Problem-Solving-Projects/blob/main/Project%201/screenshots/CloudWatch%20Dashboard.jpg?raw=true)

---

# Key Features

- Automated RDS start/stop scheduling
- Idle resource detection using CloudWatch alarms
- Event-driven optimization workflows using Lambda
- Auto Scaling support for traffic fluctuations
- Centralized CloudWatch dashboards
- SNS-based infrastructure alerting
- Modular Terraform architecture
- Least-privilege IAM access controls

---

# Key Architecture Decisions & Trade-offs

| Decision | Chosen Option | Why It Was Chosen | Trade-off |
|---|---|---|---|
| Automation Engine | AWS Lambda | Reduced infrastructure overhead through serverless execution | Cold starts may introduce minor execution delay |
| Infrastructure Provisioning | Terraform | Enabled repeatable and version-controlled infrastructure deployments | Increased initial setup and module design effort |
| Monitoring | CloudWatch | Provided native AWS observability and centralized monitoring | Monitoring costs can increase at larger scale |
| Scheduling | EventBridge | Simplified event-driven and scheduled automation workflows | Introduced dependency on AWS-managed scheduling services |
| Compute Scaling | Auto Scaling Groups | Improved infrastructure elasticity during traffic spikes | Scaling actions are not instantaneous |
| Database Optimization | RDS Scheduling | Reduced unnecessary database runtime during low-traffic periods | Database startup time may affect immediate availability |
| Networking | VPC with Public/Private Subnets | Improved workload isolation and security posture | Added networking and routing complexity |
| Notifications | SNS | Enabled lightweight infrastructure alerting workflows | Email notifications may become noisy without tuning |

---

# Fundamentals Demonstrated

| Area | Demonstrated Skills |
|---|---|
| Infrastructure as Code | Modular Terraform architecture with reusable infrastructure components |
| Cloud Networking | VPC, subnet segmentation, route tables, and security groups |
| Monitoring & Observability | CloudWatch metrics, alarms, dashboards, and infrastructure visibility |
| Event-Driven Automation | EventBridge and Lambda-based automation workflows |
| Cost Optimization | Scheduled scaling, idle resource detection, and lifecycle optimization |
| Security | IAM least-privilege access, encrypted storage, and restricted networking |
| Scalability | Auto Scaling Groups and Load Balancer integration |
| Operations | SNS alerting, monitoring workflows, and operational troubleshooting |

---

# AWS Services Used

| Service | Purpose |
|---|---|
| EC2 Auto Scaling | Scalable application infrastructure |
| RDS | Database simulation and optimization |
| Lambda | Event-driven automation workflows |
| CloudWatch | Monitoring, alarms, and observability |
| EventBridge | Scheduling and automation orchestration |
| SNS | Infrastructure notifications |
| Terraform | Infrastructure as Code provisioning |

---

# Business Impact & Results

| Metric | Outcome |
|---|---|
| Cloud Cost Reduction | Simulated reduction of 30–40% |
| Infrastructure Visibility | Improved centralized observability |
| Manual Operational Effort | Reduced through automation |
| Scalability | Improved handling of workload spikes |
| Optimization Workflows | Fully event-driven |

The project demonstrates how infrastructure automation and observability can improve cloud efficiency without introducing significant operational complexity.

## Infrastructure Cost Visibility

AWS Cost Explorer was used to monitor infrastructure spending patterns and validate optimization effectiveness across compute, database, and networking resources.

![Cost Explorer](https://github.com/swapnil-lakra/AWS-Real-World-Problem-Solving-Projects/blob/main/Project%201/screenshots/Cost%20Explorer.jpg?raw=true)
---

# Deployment

```bash
git clone https://github.com/swapnil-lakra/AWS-Real-World-Problem-Solving-Projects.git

cd "AWS-Real-World-Problem-Solving-Projects/Project 1"

terraform init
terraform plan
terraform apply -auto-approve
```

---

# Cost Optimization Techniques

- Scheduled Auto Scaling shutdown during low-traffic periods
- Automated RDS optimization workflows
- S3 lifecycle management policies
- Lambda-based serverless automation
- S3 Gateway Endpoint implementation to avoid NAT Gateway cost

The optimization strategy focused on reducing unnecessary runtime while maintaining infrastructure flexibility and scalability.

## Automated RDS Optimization

The database automatically transitions between running and stopped states based on scheduled optimization workflows and idle resource detection.

| RDS Running State | RDS Stopped State |
|---|---|
| ![RDS Running State](https://github.com/swapnil-lakra/AWS-Real-World-Problem-Solving-Projects/blob/main/Project%201/screenshots/RDS%20In%20Running%20State.jpg?raw=true) | ![RDS Stopped State](https://github.com/Swapni-1/AWS-Real-World-Problem-Solving-Projects/blob/main/Project%201/screenshots/RDS%20Stopped%20After%2020%20mins%20of%20Inactivity.jpg?raw=true) |
---

# Lessons Learned

- Modular Terraform design significantly improves maintainability and scalability
- Monitoring and observability should be implemented early in the infrastructure lifecycle
- IAM least-privilege design requires careful planning but improves long-term security posture
- Event-driven automation can significantly reduce repetitive operational workload

The project also reinforced the importance of balancing automation, infrastructure visibility, and cost optimization without introducing unnecessary architectural complexity.

---

# Future Improvements

- CI/CD pipeline integration
- Multi-region disaster recovery strategy
- Predictive scaling policies
- Advanced cost analytics and forecasting
- AWS WAF integration for additional edge security

For larger-scale workloads, container orchestration platforms such as ECS or Kubernetes could provide improved workload portability and operational flexibility.

---

# Security Considerations

The infrastructure was designed with security-focused operational practices, including:

- Private subnet architecture
- Least-privilege IAM roles
- Encrypted storage configuration
- Restricted inbound access rules
- No public database exposure

Where possible, unnecessary public exposure and static credential usage were avoided.

---

# AI Usage Note

AI tools were used primarily for early-stage idea exploration and initial Terraform drafting assistance.

All infrastructure decisions, debugging, architecture design, implementation, and validation workflows were manually reviewed, tested, and understood before deployment.

---

# Author

Swapnil Lakra  
Cloud / DevOps Engineer focused on AWS infrastructure automation, Terraform, observability, and FinOps-driven architecture design.
