resource "aws_cloudwatch_event_rule" "rds_idle_rule" {
    name = "trigger-lambda-on-rds-idle"
    description = "Trigger target when composite alarm goest to alarm state"

    # This checks pattern when specific alarm triggers
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

resource "aws_cloudwatch_event_target" "lambda_target" {
    rule = aws_cloudwatch_event_rule.rds_idle_rule.name
    target_id = "SendToLambda"
    arn = var.rds_idle_lambda_function_arn
}