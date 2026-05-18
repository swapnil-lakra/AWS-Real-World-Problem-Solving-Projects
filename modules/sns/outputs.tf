output "sns_topic_arn" {
  value       = aws_sns_topic.my_sns.arn
  description = "ARN of the SNS topic used for infrastructure monitoring, automation, and alert notifications."
}