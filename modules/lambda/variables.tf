variable "aws_region" {
  default     = "ap-south-1"
  type        = string
  description = "AWS region where all infrastructure resources and automation services will be deployed."
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group used for monitoring, scaling, and automation operations."
  type        = string
}

variable "rds_instance_identifier" {
  description = "Unique identifier of the RDS instance used for monitoring and automated start-stop operations."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used for application storage and infrastructure integration."
  type        = string
}

variable "runtime_environment" {
  default     = "python3.14"
  type        = string
  description = "Runtime environment and Python version used for Lambda function execution."
}

variable "rds_start_rule_arn" {
  type        = string
  description = "ARN of the EventBridge schedule responsible for starting the RDS instance automatically."
}

variable "rds_stop_rule_arn" {
  type        = string
  description = "ARN of the EventBridge schedule responsible for stopping the RDS instance automatically."
}

variable "rds_idle_rule_arn" {
  type        = string
  description = "ARN of the EventBridge rule triggered when the RDS idle composite alarm enters the ALARM state."
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic used for infrastructure monitoring and automation notifications."
}