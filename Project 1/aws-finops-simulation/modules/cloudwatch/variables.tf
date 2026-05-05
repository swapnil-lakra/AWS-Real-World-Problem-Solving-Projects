variable "aws_region" {
  description = "Value of current aws region"
  type = string
  default = "ap-south-2"
}

variable "asg_name" {
  description = "Name of Auto Scaling Group"
  type = string
}


variable "rds_instance_identifier" {
  description = "RDS instance identifier"
  type = string
}


variable "s3_bucket_name" {
  description = "S3 bucket name"
  type = string
}

variable "sns_topic_arn" {
  description = "arn of sns topic"
  type = string
}

variable "aws_lambda_function_rds_optimizer_arn" {
  description = "ARN value of lambda function"
  type = string
}

variable "aws_lambda_function_s3_optimizer_arn" {
  description = "ARN value of lambda function"
  type = string
}

variable "aws_iam_lambda_role_arn" {
  description = "ARN value of lambda iam role"
  type = string
}

variable "rds_stop_lambda_arn" {
  description = "Arn value of Stop_Lambda"
  type = string
}

variable "rds_start_lambda_arn" {
  description = "Arn value of Start_Lambda"
  type = string
}