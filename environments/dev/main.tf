# WHY:
# VPC module creates the foundational network infrastructure for the entire environment.
# It isolates resources securely using public and private subnet architecture.

module "my_vpc" {
  source = "../../modules/vpc"
}

# WHY:
# Security group module manages network-level access control between infrastructure components.
# It restricts traffic flow using least-privilege security principles.

module "my_sg" {
  source = "../../modules/security-group"

  vpc_id = module.my_vpc.vpc_id
}

# WHY:
# S3 module provisions storage resources, IAM instance profiles,
# and private S3 connectivity using a Gateway Endpoint.

module "my_s3_bucket" {
  source = "../../modules/s3"

  vpc_id = module.my_vpc.vpc_id

  public_route_table_id  = module.my_vpc.public_route_table_id
  private_route_table_id = module.my_vpc.private_route_table_id
  s3_delete_alert_arn    = module.my_sns.sns_topic_arn
}

# WHY:
# Auto Scaling module deploys scalable web application infrastructure.
# It handles traffic spikes automatically using ASG and Application Load Balancer integration.

module "auto_scaling_group" {
  source = "../../modules/ec2 auto-scaling"

  vpc_id = module.my_vpc.vpc_id

  # WHY:
  # Public subnets are used for the internet-facing Application Load Balancer.

  public_subnet_ids = [
    module.my_vpc.public_subnet_1_id,
    module.my_vpc.public_subnet_2_id
  ]

  # WHY:
  # Private subnets are used for backend EC2 instances to improve infrastructure security.

  private_subnet_ids = [
    module.my_vpc.private_subnet_1_id,
    module.my_vpc.private_subnet_2_id
  ]

  #alb_sg_id = module.my_sg.alb_sg_id 
  asg_sg_id = module.my_sg.asg_sg_id

  # WHY:
  # IAM instance profile allows EC2 instances to securely access S3 resources.

  ec2_instance_profile_name = module.my_s3_bucket.ec2_instance_profile_name
}

# WHY:
# RDS module creates the backend database infrastructure inside private subnets.
# It simulates an overprovisioned database for FinOps optimization testing.

module "my_rds" {
  source = "../../modules/rds"

  private_subnet_ids = [
    module.my_vpc.private_subnet_1_id,
    module.my_vpc.private_subnet_2_id
  ]

  rds_sg_id = module.my_sg.rds_sg_id
}

# WHY:
# CloudWatch module provides centralized monitoring, alarms, dashboards,
# and observability across EC2, RDS, and S3 resources.

module "my_cloudwatch" {
  source = "../../modules/cloudwatch"

  asg_name                = module.auto_scaling_group.asg_name
  rds_instance_identifier = module.my_rds.db_instance_identifier
  s3_bucket_name          = module.my_s3_bucket.bucket_name

  sns_topic_arn = module.my_sns.sns_topic_arn
}

# WHY:
# EventBridge module handles event-driven automation and scheduling workflows.
# It connects monitoring events with Lambda-based optimization actions.

module "my_event-bridge" {
  source = "../../modules/event-bridge"

  rds_stop_lambda_arn  = module.finops_lambda.rds_stop_lambda_arn
  rds_start_lambda_arn = module.finops_lambda.rds_start_lambda_arn

  rds_instance_identifier = module.my_rds.db_instance_identifier

  rds_idle_lambda_function_arn = module.finops_lambda.aws_lambda_function_rds_idle_stop_arn
  asg_schedule_alerts_arn      = module.my_sns.sns_topic_arn
}

# WHY:
# Lambda module contains automation logic for RDS optimization workflows.
# It performs scheduled start/stop actions and idle resource optimization.

module "finops_lambda" {
  source = "../../modules/lambda"

  asg_name                = module.auto_scaling_group.asg_name
  rds_instance_identifier = module.my_rds.db_instance_identifier

  s3_bucket_name = module.my_s3_bucket.bucket_name

  rds_idle_rule_arn  = module.my_event-bridge.rds_idle_rule_arn
  rds_start_rule_arn = module.my_event-bridge.rds_start_rule_arn
  rds_stop_rule_arn  = module.my_event-bridge.rds_stop_rule_arn

  sns_topic_arn = module.my_sns.sns_topic_arn
}

# WHY:
# SNS module provides centralized notification and alerting infrastructure.
# Used by CloudWatch alarms and Lambda functions for operational visibility.

module "my_sns" {
  source        = "../../modules/sns"
  s3_bucket_arn = module.my_s3_bucket.bucket_arn
}