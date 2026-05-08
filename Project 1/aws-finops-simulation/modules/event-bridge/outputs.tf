output "rds_start_rule_arn" {
  value = aws_scheduler_schedule.rds_start_daily.arn
}

output "rds_stop_rule_arn" {
  value = aws_scheduler_schedule.rds_stop_daily.arn
}

output "rds_idle_rule_arn" {
  value = aws_cloudwatch_event_rule.rds_idle_rule.arn
}