output "dashboard_name" {
  description = "ARN of the CloudWatch dashboard used for centralized infrastructure monitoring and observability."
  value       = aws_cloudwatch_dashboard.finops_dashboard.dashboard_arn
}

output "dashboard_arn" {
  description = "Name of the CloudWatch dashboard displaying infrastructure metrics, alarms, and operational insights."
  value       = aws_cloudwatch_dashboard.finops_dashboard.dashboard_name
}