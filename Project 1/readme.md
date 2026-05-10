# AutoFinOps: Real-Time Cloud Cost Optimization Platform for SaaS (AWS) ✅

> Cut cloud waste by **30–40%**, reducing monthly spend from **₹50L to ~₹30L**, saving **₹1–₹1.5 crore annually** while improving **cost visibility** and **operational efficiency**. ✅

# Business Problem ✅
A mid-sized SaaS company on Amazon Web Services spends **₹35–₹50 lakhs monthly**, with **25–40% wasted** due to idle compute, over-provisioned databases, and unused storage. Despite **predictable workloads**, the **lack of real-time cost visibility** and **automated optimization** leads to consistent **over-provisioning** and **billing spikes**. A **small DevOps team**, without a **dedicated FinOps practice**, cannot efficiently manage optimization across **50+ services** without risking reliability. If unresolved, this could result in **₹1–₹1.5 crore in annual losses**, directly impacting **profitability** and limiting **future growth**. ✅

# Solution Overview & Architecture (This section needs improvement)
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

# Architecture Diagram (This Diagram should be replaced with updated one)
![FinOps Architecture Diagram](https://raw.githubusercontent.com/Swapni-1/AWS-Real-World-Problem-Solving-Projects/refs/heads/main/Project%201/assets/FinOps%20Architecture%20Diagram.jpg)

# Key Architecture Decisions & Trade-offs (improvement needed)

| Decision | Chosen Option | Why This Over Alternative | Trade-off / Risk Mitigated |
|----------|---------------|---------------------------|----------------------------|
| Compute Automation | AWS Lambda | Serverless automation removed the need to run dedicated EC2 automation servers and reduced operational overhead. | Cold starts may slightly increase execution latency, but infrastructure cost and maintenance effort were minimized. |
| Scheduling | Event-Bridge Scheduler | Native AWS scheduling service integrates directly with Lambda and supports cron-based automation without managing external schedulers. | Adds dependency on AWS-managed scheduling services, but eliminates manual cron management and improves reliability. |
| Scheduling Auto-Scaling Groups | Auto-Scaling  Schedule | Scheduled scaling matched predictable SaaS traffic patterns more efficiently than keeping instances running 24×7. | Sudden traffic outside scheduled windows may temporarily increase response time, but idle infrastructure cost was significantly reduced. |
| Monitoring | CloudWatch Custom Dashboard | Centralized monitoring provided visibility across EC2, RDS, alarms, scaling events, and storage metrics in one place. | CloudWatch metrics and dashboards can generate additional cost at scale, but operational visibility and troubleshooting improved greatly. |
| Handling Unpredictable Traffic Spike | Auto-Scaling Groups | Automatically scaled compute resources during sudden 3–5× traffic spikes instead of manual intervention. | Scaling is not instant and may take time during large spikes, but infrastructure stability and availability improved. |
| Storage Optimization | S3 Bucket | Lifecycle policies, encryption, metrics, and low operational management made S3 suitable for storage optimization simulation. | Misconfigured lifecycle rules can accidentally delete important data, but unused storage cost and storage sprawl were reduced. | 
| Database Optimization | RDS | Managed database reduced administrative overhead and allowed simulation of overprovisioned workloads with automated scheduling. | RDS stop/start has startup delay and cannot scale instantly, but database management complexity was reduced. |
| Networking | VPC | Isolated public and private subnet architecture improved security and better simulated real SaaS infrastructure design. | More networking complexity compared to default VPC setup, but security and traffic isolation improved significantly. |
| Security | IAM | IAM roles and least-privilege policies allowed secure service-to-service communication without hardcoded credentials. | Incorrect IAM policies can break automation workflows, but security risks and credential exposure were minimized. |
| Alert Messaging | SNS | SNS enabled centralized real-time notifications from CloudWatch alarms and Lambda automation workflows. | Email-based alerts may be delayed or ignored during alert fatigue, but operational awareness improved significantly. | 

## Design Thinking
| AWS Service | Purpose | Why It Was a Good Fit |
| ----------- |-------- |---------------------- |
| Amazon EC2 Auto Scaling | Automatically scaled application servers based on predictable traffic and sudden spikes. | Perfect for simulating real SaaS traffic behavior while optimizing idle compute cost. |
| Amazon RDS | Simulated an overprovisioned production database with automated start/stop optimization. | Ideal for demonstrating database cost optimization and idle resource automation. | 
| Amazon CloudWatch | Monitored infrastructure metrics, alarms, dashboards, and idle resource detection. | Best suited for centralized observability and real-time FinOps monitoring. | 
| AWS Lambda | Automated RDS start/stop and idle optimization workflows. | Serverless execution removed the need to manage dedicated automation servers. | 
| Amazon EventBridge | Triggered scheduled and event-driven automation workflows. | Perfect for building reliable automation without managing cron servers manually. | 
| Amazon VPC | Provided isolated networking using public/private subnet architecture. | Closely matched real-world SaaS infrastructure security and traffic isolation patterns. | Closely matched real-world SaaS infrastructure security and traffic isolation patterns. | 


## Infrastructure as Code – 100% Terraform
- “Everything is defined as code. No ClickOps was used in production setup.”
- Key highlights:
  - Modular structure (show folder tree)
  - `terraform apply` deploys the entire environment in < 3 minutes
  - Variables, outputs, and state management explained
  - How you would recreate the exact environment in another region/AZ

## Folder Structure
```text
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

# Deployment Instructions
## Clone Repository
```bash
git clone https://github.com/Swapni-1/AWS-Real-World-Problem-Solving-Projects.git

cd "AWS-Real-World-Problem-Solving-Projects/Project 1"
```

## Initialize Terraform
```bash
terraform init
```

## Review Execution Plan
```bash
terraform plan
```

## Deploy Infrastructure 
```bash
terraform apply -auto-approve
```
# Prerequisites
## AWS Acount
At least one 
## Tools
## AWS Authentication

## Configuration / Variables

## Validation & Testing

## Business Impact & Results

## Cost Optimization Notes (Free-Tier / Low-Cost)

## Monitoring & Operations

# Troubleshooting / Incident Recovery Guide

## ALB Returns `503 Service Unavailable`
**Possible Causes**
- No healthy targets registered in the Target Group
- ASG instances failed health checks
- Web server `(httpd)` not running
- Incorrect security group rules

**Troubleshooting Steps**
- Verify target health in:
- [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) → Target Groups
- Check EC2 instance status
- Verify `httpd` service:
```bash
sudo systemctl status httpd
```
- Check ALB and ASG security group rules
- Verify target group health check path

**Recovery Actions**
- Restart `httpd`
- Re-register unhealthy targets
- Fix security group rules
- Relaunch unhealthy ASG instances

## EC2 User Data Script Failed
**Symptoms**
- Apache not installed
- Website not accessible
- Application files missing

**Troubleshooting Steps**

Check cloud-init logs:

```bash
sudo cat /var/log/cloud-init-output.log
```

Check system logs:

```bash
sudo journalctl -xe
```


**Recovery Actions**
- Fix script syntax errors
- Validate package installation commands
- Relaunch instance after updating Launch Template

## ASG Instances Not Scaling
**Possible Causes**
- Incorrect scaling policy configuration
- CloudWatch alarm not triggering
- CPU utilization not crossing threshold

**Troubleshooting Steps**
- Verify ASG metrics in:
  - [Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html)
- Check scaling policy thresholds
- Validate Target Tracking policy configuration

**Recovery Actions**
- Adjust scaling thresholds
- Verify CloudWatch metric dimensions
- Trigger controlled load testing using:
  - Apache JMeter

## Sudden Traffic Spike Causes High Response Time

**Symptoms**
- Slow website response
- Increased CPU usage
- High ALB latency

**Troubleshooting Steps**
- Check ASG scaling activity
- Monitor ALB request count
- Verify instance health

**Recovery Actions**
- Increase ASG maximum capacity
- Optimize scaling cooldowns
- Use predictive or request-based scaling policies

## RDS Not Starting or Stopping Automatically
**Possible Causes**
- EventBridge schedule misconfiguration
- Lambda permission issues
- IAM role missing permissions
- Troubleshooting Steps

Check:

- Amazon EventBridge schedules
- Lambda execution logs
- IAM role permissions

Verify Lambda logs:
```bash
CloudWatch Logs → Lambda Log Group
```
**Recovery Actions**
- Correct EventBridge cron expressions
- Reattach required IAM permissions
- Retest Lambda manually

## Idle RDS Detection Not Working
**Possible Causes**
- CloudWatch alarms not entering ALARM state
- Composite alarm rule issue
- EventBridge event pattern mismatch

**Troubleshooting Steps**
- Verify:
  - CPUUtilization metric
  - DatabaseConnections metric
- Validate composite alarm logic
- Confirm EventBridge rule matches alarm name exactly

**Recovery Actions**
- Fix metric thresholds
- Validate alarm evaluation periods
- Re-trigger alarms manually for testing

## Lambda Function Execution Failure
**Symptoms**
- Automation not running
- RDS not stopping
- No SNS notifications

**Troubleshooting Steps**

Check Lambda logs:
- AWS Lambda → CloudWatch Logs

Verify:
- environment variables
- boto3 logic
- IAM permissions

**Recovery Actions**
- Fix Python runtime errors
- Add missing IAM permissions
- Re-deploy Lambda package

## SNS Notifications Not Received
**Possible Causes**
- Email subscription not confirmed
- Incorrect SNS topic ARN
- Alarm actions misconfigured
**Troubleshooting Steps** 
- Verify SNS subscriptions
- Check CloudWatch alarm actions
- Confirm SNS topic configuration
**Recovery Actions**
- Re-confirm email subscription
- Update alarm action ARN
- Test SNS publishing manually

## S3 Access Fails from Private ASG Instances
**Possible Causes**
- Incorrect IAM role
- Missing Instance Profile
- S3 Gateway Endpoint issue

**Troubleshooting Steps**

Verify:
- IAM role attachment
- Instance profile association
- S3 VPC endpoint route tables

Test connectivity:
```bash
aws s3 ls
```

**Recovery Actions**
- Reattach IAM role
- Fix VPC endpoint routing
- Restart affected instances

## Terraform State Lock Error
**Symptoms**
```bash
Error acquiring the state lock
```
**Possible Causes**
- Previous Terraform operation interrupted
- DynamoDB lock still active

**Troubleshooting Steps**

Check:
- Amazon DynamoDB lock table
- Active Terraform processes

**Recovery Actions**

Force unlock:
```bash
terraform force-unlock LOCK_ID
```

## Terraform Apply Fails Due to Dependency Issues
**Possible Causes**
- Resource ordering issue
- Missing variable values
- Incorrect module outputs
**Troubleshooting Steps**
- Run:
```bash
terraform validate
terraform plan
```
- Verify module references and outputs

**Recovery Actions**
- Correct dependencies
- Fix variable mappings
- Validate module outputs

12. Security Group Connectivity Issues
**Symptoms**
- ALB cannot reach ASG
- ASG cannot connect to RDS

**Troubleshooting Steps**

Verify:
- inbound rules
- referenced security group IDs
- subnet routing

Use:
- AWS Reachability Analyzer

**Recovery Actions**
- Correct SG rules
- Fix port configurations
- Verify route tables

## CloudWatch Alarm Never Triggers
**Possible Causes**
- Incorrect metric dimensions
- Wrong evaluation periods
- Alarm state never changes

**Troubleshooting Steps**
- Verify namespace and dimensions
- Confirm metric values exist
- Review alarm history

**Recovery Actions**
- Fix dimensions
- Adjust thresholds
- Generate test traffic/load

## ASG Scheduled Scaling Does Not Work
**Possible Causes**
- Incorrect cron expression
- Timezone mismatch
- Desired capacity conflicts

**Troubleshooting Steps**

Verify:
- ASG schedules
- timezone settings
- scaling activities

**Recovery Actions**
- Correct cron timing
- Validate Asia/Kolkata timezone
- Retest schedules manually

## Infrastructure Drift

**Symptoms**
- Manual changes not reflected in Terraform

**Troubleshooting Steps**

Run:
```bash
terraform plan
```

**Recovery Actions**
- Reconcile infrastructure changes
- Avoid manual console modifications
- Re-apply Terraform configuration

## Incident Recovery Strategy
**Immediate Response**
- Identify affected component
- Analyze CloudWatch metrics and logs
- Validate recent infrastructure changes

**Containment**
- Prevent further automation impact
- Disable problematic schedules or alarms temporarily

**Recovery**
- Restore healthy infrastructure state
- Relaunch affected services if required

**Validation**
- Re-test monitoring, alarms, scaling, and automation workflows

**Post-Incident Review**
- Identify root cause
- Document lessons learned
- Improve automation or monitoring logic

# Lessons Learned & What I Would Change
## Lessons Learned

- Using a modular structure in Terraform significantly improves infrastructure maintainability, scalability, and code reusability.

- Monitoring should be implemented early in the infrastructure lifecycle instead of being added later.

- Amazon CloudWatch alarms trigger only when the alarm state changes (for example, from `OK` to `ALARM` or `ALARM` to `OK`).

- Proper subnet planning is important because subnet CIDR ranges inside a VPC must not overlap.

- Route table associations help control how specific subnets communicate with internal and external networks.

- Security groups can reference other security groups to allow controlled inbound access only from approved resources.

- Using Application Load Balancer with an Auto Scaling Group provides a single entry point while distributing traffic across multiple instances.

- Consistent resource tagging improves cost allocation, governance, automation, operational visibility, and resource management.

- Custom monitoring dashboards provide centralized visibility across infrastructure resources and operational metrics.

- Following the IAM least privilege principle is critical to avoid unnecessary permissions and reduce security risks.

- IAM roles are the preferred way for AWS resources to securely access other AWS services.

- Selecting the correct monitoring metrics is essential for accurate infrastructure analysis and optimization decisions.

- User data script issues can be debugged effectively using EC2 system logs and cloud-init logs.

- An Amazon S3 bucket must be emptied before it can be deleted.

- AWS Lambda execution issues can be debugged efficiently using CloudWatch Logs.

- Network connectivity and routing issues can be analyzed using AWS Reachability Analyzer.

- Lambda functions should be tested independently before integrating them into automation workflows.

- Event-driven automation becomes highly effective when Amazon EventBridge, CloudWatch alarms, and Lambda functions are integrated together.

- Automation workflows should always be tested thoroughly to validate expected behavior and avoid accidental infrastructure impact.

- Troubleshooting and debugging are essential parts of infrastructure engineering and often take significant effort during implementation.


## Future Improvements

- I would implement predictive and request-based auto scaling instead of relying primarily on CPU-based scaling to handle sudden traffic spikes more efficiently.

- I would add Multi-AZ database deployment to improve high availability and reduce the risk of a single point of failure.

- I would enhance the monitoring strategy by including memory usage, latency, disk throughput, and application-level metrics instead of relying mainly on CPU and database connections.

- I would build a near real-time cost estimation system because native AWS billing metrics can have delays.

- I would implement automated rightsizing recommendations based on historical resource utilization patterns.

- I would strengthen security by integrating services such as AWS WAF and AWS Secrets Manager for better protection and secret management.

- I would improve the load testing architecture by using distributed load generators instead of relying on a single load testing instance.

- I would introduce automated tag compliance checks to ensure all infrastructure resources follow governance standards consistently.

- I would integrate CI/CD pipelines for automated infrastructure deployments and validation workflows.

- I would further optimize the Terraform architecture by creating more reusable modules and multi-environment deployment support.

- I would implement intelligent self-healing automation to automatically remediate underutilized or unhealthy resources.

- I would add backup validation and disaster recovery testing to improve operational resiliency.

- I would improve automation safety by adding approval workflows and rollback mechanisms for critical optimization actions.


# Engineering Mindset & Problem Solving Approach

Several components in this project were initially unfamiliar, including:

- Terraform state management

- VPC CIDR blocks, public subnets, and private subnets
- Security Groups and restricted inbound rules
- User data script debugging
- Auto Scaling Groups, scaling policies, and scheduled scaling
- Application Load Balancer and its core components
- AWS SSM Parameter Store (`SecureString`)
- Amazon S3 bucket encryption using SSE
- Amazon CloudWatch metrics, alarms, widgets, and custom dashboards
- Amazon EventBridge rules, targets, and scheduling
- AWS Lambda execution flow and debugging
- IAM roles, policies, and permission troubleshooting
- Event-driven automation workflows
- Cost optimization techniques
- Infrastructure tagging strategies

## Approach Used

- Gradually became familiar with each component before integrating it into the architecture.

- Researched and learned the fundamentals, practical usage, and integration patterns of each AWS service.

- Broke complex problems into smaller tasks to simplify troubleshooting and implementation.

- Focused on root cause analysis instead of relying on temporary fixes or shortcuts.

- Used CloudWatch Logs extensively for debugging infrastructure, Lambda functions, and automation workflows.

- Validated each AWS service independently before integrating it into the complete system.

- Continuously tested automation workflows to ensure expected behavior and reliability.

- Prioritized understanding how different AWS services communicate and interact within a real-world architecture.

# Future Enhancements
- Multi-AZ High Availability

- Predictive Cost Forecasting
- Advanced Rightsizing Engine
- Spot Instance Integration
- Tag Compliance Automation
- Self-Healing Infrastructure
- Containerization & Kubernetes
- Distributed Load Testing
- Real-Time Cost Estimation Engine
- CI/CD Integration
- Security Enhancements
- Cost Allocation per Team / Environment
- Intelligent Auto Scaling
- Disaster Recovery Strategy

# Screenshots / Live Demo

## Architecture Diagram
(Add Screenshot)

## CloudWatch Metrics Dashboard
(Add Screenshot)

## Terraform Deployment Output
(Add Screenshot) 



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
- encrypted storage and database credentials
- private subnets
- security groups (restricted inbound rules)
- no public database access
- restriction on public S3 bucket access
- S3 bucket gateway (private connectivity)
- 3-Tier Architecture


# AI Usage Note
AI tools such as ChatGPT and Claude were used only for initial idea exploration and Terraform draft assistance.

All infrastructure decisions, debugging, architecture design, testing and implementation were manually reviewed and validated before deployment.

# Author

Swapnil Lakra

Cloud Engineer  
Focused on AWS, Terraform, FinOps, and scalable infrastructure automation.

