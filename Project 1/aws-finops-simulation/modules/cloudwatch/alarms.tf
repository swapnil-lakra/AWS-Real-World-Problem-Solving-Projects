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
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  treat_missing_data = "notBreaching" # if instance stops then stop the alarm
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
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

