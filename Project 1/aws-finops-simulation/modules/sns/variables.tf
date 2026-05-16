variable "sns_topic_name" {
  default     = "finops-alerts-topic"
  type        = string
  description = "Name of the SNS topic used for infrastructure monitoring and automation alert notifications."
}

variable "s3_bucket_arn" {
   type = string
   description = "ARN of the S3 bucket used for storage operations, event notifications, and IAM policy access control"
}