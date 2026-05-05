output "dashboard_name" {
  description = "ARN of the CloudWatch dashboard"
  value = aws_cloudwatch_dashboard.finops_dashboard.dashboard_arn
}

output "dashboard_arn" {
  description = "Name of the dashboard"
  value = aws_cloudwatch_dashboard.finops_dashboard.dashboard_name
}

output "rds_start_rule_arn" {
  value = aws_scheduler_schedule.rds_start_daily.arn
}

output "rds_stop_rule_arn" {
  value = aws_scheduler_schedule.rds_stop_daily.arn
}

output "rds_idle_scheduler_rule_arn" {
  value = aws_scheduler_schedule.rds_stop_low_cpu.arn
}

output "s3_unused_scheduler_rule_arn" {
  value = aws_scheduler_schedule.s3_cleanup.arn
}