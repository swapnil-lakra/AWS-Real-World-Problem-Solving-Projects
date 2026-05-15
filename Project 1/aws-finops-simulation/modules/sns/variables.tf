variable "sns_topic_name" {
  default     = "finops-alerts-topic"
  type        = string
  description = "Name of the SNS topic used for infrastructure monitoring and automation alert notifications."
}