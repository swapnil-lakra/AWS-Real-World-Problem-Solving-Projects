# 1. ASG - Idle Alarm (Group Average CPU < 5% for 15 mins)
resource "aws_cloudwatch_metric_alarm" "asg_idle" {
  alarm_name = "asg-idle-cpu-below-5-percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300 
  statistic = "Average"
  threshold = 5
  alarm_description = "Alarm if ASG average CPU < 5% for 15 minutes"
  actions_enabled = true
  alarm_actions = [ var.sns_topic_arn ]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  treat_missing_data = "notBreaching" # if instance stops then stop the alarm

  tags = {
    Name        = "asg-idle-alarm"

    Role        = "monitoring"
    Workload    = "asg"
    Tier        = "observability"

    Purpose     = "idle-resource-detection"

    Metric      = "cpu-utilization"
    Threshold   = "below-5-percent"

    Action      = "sns-notification"

    Optimization = "enabled"
    Criticality  = "high"
  }
}

# 2. ASG - Overload Alarm (Group Average CPU >= 60% for 10 minutes)
resource "aws_cloudwatch_metric_alarm" "asg_overload" {
  alarm_name = "asg-cpu-overload-above-60-percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2 # 2 periods - 10 mins if period 300
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300 # 5 minutes
  statistic = "Average"
  threshold = 60
  alarm_description = "Alarm if ASG average CPU >= 60% for 10 minutes"
  actions_enabled = true
  alarm_actions = [var.sns_topic_arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  tags = {
    Name        = "asg-overload-alarm"

    Role        = "monitoring"
    Workload    = "asg"
    Tier        = "observability"

    Purpose     = "traffic-spike-detection"

    Metric      = "cpu-utilization"
    Threshold   = "above-60-percent"

    Action      = "sns-notification"

    Scenario    = "predictable-with-spikes"

    Optimization = "enabled"
    Criticality  = "high"
  }
}

# 3. RDS - Idle Alarm (CPU < 5% for 20 mins)
resource "aws_cloudwatch_metric_alarm" "rds_idle_cpu" {
  alarm_name = "rds-idle-cpu-below-5-percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 4 # 4 periods - 20 mins if period 300
  metric_name = "CPUUtilization"
  namespace = "AWS/RDS"
  period = 300 # 5 minutes
  statistic = "Average"
  threshold = 5
  alarm_description = "Alarm if RDS cpu utilization < 5% for 20 minutes"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }

  tags = {
    Name        = "rds-idle-cpu-alarm"

    Role        = "monitoring"
    Workload    = "rds"
    Tier        = "observability"

    Purpose     = "idle-database-detection"

    Metric      = "cpu-utilization"
    Threshold   = "below-5-percent"

    Scenario    = "overprovisioned-database"

    Optimization = "enabled"
    Criticality  = "high"
  }
}

# 4. RDS - No Connection (Database Connection < 5% for 20 mins)
resource "aws_cloudwatch_metric_alarm" "rds_zero_connections" {
  alarm_name = "rds-zero-connections"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 4 # 4 periods - 20 mins if period 300
  metric_name = "DatabaseConnections"
  namespace = "AWS/RDS"
  period = 300 # 5 minutes
  statistic = "Average"
  threshold = 1
  alarm_description = "Alarm if RDS database connections < 1 for 20 minutes"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }

  tags = {
    Name        = "rds-zero-connections-alarm"

    Role        = "monitoring"
    Workload    = "rds"
    Tier        = "observability"

    Purpose     = "database-connection-monitoring"

    Metric      = "database-connections"
    Threshold   = "below-1"

    Scenario    = "idle-database-detection"

    Optimization = "enabled"
    Criticality  = "high"
  }
}

# Composite Alarm for RDS Idle (CPU < 5% AND Connections < 1 for 20 mins)
resource "aws_cloudwatch_composite_alarm" "rds_idle_composite" {
  alarm_name = "rds-idle-composite-alarm"
  alarm_description = "Composite alarm for RDS idle state (CPU < 5% AND Connections < 1 for 20 mins)"
  actions_enabled = true
  alarm_actions = [var.sns_topic_arn]

  alarm_rule = "ALARM(${aws_cloudwatch_metric_alarm.rds_idle_cpu.alarm_name}) AND ALARM(${aws_cloudwatch_metric_alarm.rds_zero_connections.alarm_name})"

  tags = {
    Name        = "rds-idle-composite-alarm"

    Role        = "composite-monitoring"
    Workload    = "rds"
    Tier        = "observability"

    Purpose     = "intelligent-idle-detection"

    Monitoring  = "cpu-and-db-connections"

    Scenario    = "idle-overprovisioned-rds"

    Action      = "lambda-trigger"

    Optimization = "enabled"
    Criticality  = "high"
  }  
}