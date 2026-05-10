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

# WHY:
# EventBridge target connects the alarm event rule to the Lambda automation function.
# This enables automatic execution of RDS stop logic when idle conditions are detected.

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.rds_idle_rule.name
  target_id = "SendToLambda"
  arn       = var.rds_idle_lambda_function_arn
}