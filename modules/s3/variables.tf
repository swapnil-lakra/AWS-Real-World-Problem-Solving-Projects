variable "bucket_name" {
  default     = "ec2_s3_profile"
  type        = string
  description = "Name used for the EC2 IAM instance profile that provides secure access to S3 resources."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the S3 Gateway Endpoint will be deployed."
}

variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region where the infrastructure resources are created and managed."
}

variable "public_route_table_id" {
  type        = string
  description = "ID of the public route table associated with internet-facing subnet routing."
}

variable "private_route_table_id" {
  type        = string
  description = "ID of the private route table used for internal backend subnet routing."
}

variable "s3_delete_alert_arn" {
  type = string

  description = "ARN of the SNS topic used for S3 object deletion event notifications"
}