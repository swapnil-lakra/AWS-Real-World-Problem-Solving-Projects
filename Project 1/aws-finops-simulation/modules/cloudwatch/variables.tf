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