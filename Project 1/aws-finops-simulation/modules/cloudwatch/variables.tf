variable "aws_region" {
  description = "AWS region where monitoring, automation, and infrastructure resources are deployed."
  type        = string
  default     = "ap-south-2"
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group used for infrastructure monitoring and scaling operations."
  type        = string
}

variable "rds_instance_identifier" {
  description = "Unique identifier of the RDS instance used for monitoring and automation workflows."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used for storage monitoring and infrastructure integration."
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic used for CloudWatch alarm notifications and operational alerts."
  type        = string
}