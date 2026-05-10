output "rds_start_rule_arn" {
  value       = aws_scheduler_schedule.rds_start_daily.arn
  description = "ARN of the EventBridge Scheduler rule used to automatically start the RDS instance during business hours."
}

output "rds_stop_rule_arn" {
  value       = aws_scheduler_schedule.rds_stop_daily.arn
  description = "ARN of the EventBridge Scheduler rule used to automatically stop the RDS instance during idle hours."
}

output "rds_idle_rule_arn" {
  value       = aws_cloudwatch_event_rule.rds_idle_rule.arn
  description = "ARN of the EventBridge rule triggered when the RDS idle composite alarm enters the ALARM state."
}