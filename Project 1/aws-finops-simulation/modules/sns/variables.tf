variable "sns_topic_name" {
  default     = "finops-alerts-topic"
  type        = string
  description = "Name of the SNS topic used for infrastructure monitoring and automation alert notifications."
}

variable "alert_email" {
  default     = "swapnil.cloud.dev@hotmail.com"
  type        = string
  description = "Email address subscribed to receive CloudWatch alarms and operational alert notifications."
}