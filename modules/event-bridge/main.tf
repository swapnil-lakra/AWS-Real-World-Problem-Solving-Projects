# WHY:
# EventBridge rule listens for CloudWatch alarm state changes related to idle RDS detection.
# It enables event-driven automation when the RDS composite alarm enters the ALARM state.

resource "aws_cloudwatch_event_rule" "rds_idle_rule" {
  name        = "trigger-lambda-on-rds-idle"
  description = "Trigger target when composite alarm goest to alarm state"

  # WHY:
  # Event pattern filters only the specific RDS composite alarm event.
  # This ensures automation triggers only when both idle conditions are satisfied.

  event_pattern = jsonencode({
    "source" : ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "detail": {
      "alarmName": ["rds-idle-composite-alarm"],
      "state": {
        "value": ["ALARM"]
      }
    }
  })

  tags = {
    Name        = "rds-idle-event-rule"

    Role        = "event-trigger"
    Workload    = "eventbridge"
    Tier        = "automation"

    Purpose     = "idle-rds-detection"

    Monitoring  = "cloudwatch-composite-alarm"

    TriggerCondition = "cpu-lessthan-5-and-dbconnections-equals-0"

    Automation  = "enabled"

    Criticality = "high"
  }
}

# Capture ASG Scheduled Action Events
# WHY:
# Monitors Auto Scaling scheduled start/stop executions to improve
# operational visibility and track automated infrastructure changes.


resource "aws_cloudwatch_event_rule" "asg_schedule_rule" {
  name        = "capture-asg-scheduled-actions"
  description = "Triggers when ASG executing scheduled start or stop actions"

  event_pattern = jsonencode({
    "source": ["aws.autoscaling"],
    "detail-type": ["EC2 Auto Scaling Scheduled Action Execution"]
  })

  tags = {
    Name        = "asg-schedule-event-rule"

    Role        = "event-monitoring"
    Workload    = "eventbridge"
    Tier        = "automation"

    Purpose     = "asg-schedule-tracking"

    Monitoring  = "asg-scheduled-actions"

    EventSource = "aws-autoscaling"

    Automation  = "enabled"

    Alerting    = "sns-integrated"

    Criticality = "medium"
  }
}

# WHY:
# EventBridge target connects the alarm event rule to the Lambda automation function.
# This enables automatic execution of RDS stop logic when idle conditions are detected.

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.rds_idle_rule.name
  target_id = "SendToLambda"
  arn       = var.rds_idle_lambda_function_arn
}

# Send ASG Schedule Events to SNS
# WHY:
# Sends real-time notifications whenever Auto Scaling scheduled actions
# are executed, helping operators verify automation behavior and schedules.

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.asg_schedule_rule.name
  target_id = "SendToSNS"
  arn       = var.asg_schedule_alerts_arn
}

