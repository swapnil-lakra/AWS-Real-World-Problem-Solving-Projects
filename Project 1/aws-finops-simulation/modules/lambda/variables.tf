variable "aws_region" {
  default = "ap-south-2"
  type = string
  description = "AWS Region where resources will be created"
}

variable "asg_name" {
  description = "Name of Auto Scaling Group"
  type =  string
}

variable "rds_instance_identifier" {
  description = "Unique identifier of rds instance"
  type = string
}

variable "s3_bucket_name" {
  description = "Name of S3 Bucket"
  type = string
}

variable "runtime_environment" {
  default = "python3.14"
  type = string
  description = "Name and version of runtime environment"
}

variable "rds_start_rule_arn" {
  type = string
  description = "ARN of start rds rule"
}

variable "rds_stop_rule_arn" {
  type = string
  description = "ARN of stop rds rule"
}

variable "rds_idle_rule_arn" {
  type = string
  description = "ARN of idle rds rule"
}

variable "sns_topic_arn" {
  type = string
  description = "ARN of SNS Topic"
}