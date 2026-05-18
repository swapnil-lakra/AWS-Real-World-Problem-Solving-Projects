# WHY:
# IAM role allows EventBridge Scheduler to securely invoke Lambda functions.
# This enables automated RDS start and stop operations without manual intervention.

resource "aws_iam_role" "scheduler_role" {
  name = "rds-s3-scheduler-role"

  # WHY:
  # Trust policy allows the EventBridge Scheduler service to assume this IAM role.
  # Without this trust relationship, the scheduler cannot execute automation tasks.

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"

      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "scheduler-role"

    Role        = "scheduler-execution-role"
    Workload    = "iam"
    Tier        = "automation"

    Purpose     = "lambda-invocation"

    Access      = "internal"

    Automation  = "enabled"

    Permissions = "lambda-invoke"

    Criticality = "high"
  }
}

# WHY:
# IAM policy grants permission to invoke the RDS start and stop Lambda functions.
# This follows least-privilege access by allowing only required Lambda actions.

resource "aws_iam_role_policy" "scheduler_policy" {
  name = "rds-s3-scheduler-policy"
  role = aws_iam_role.scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "LambdaInvocation"
        Effect = "Allow"

        Action = [
          "lambda:InvokeFunction"
        ]

        Resource = [
          "${var.rds_stop_lambda_arn}",
          "${var.rds_start_lambda_arn}"
        ]
      }
    ]
  })
}

# WHY:
# EventBridge Scheduler automatically starts the RDS instance before business hours begin.
# This simulates predictable enterprise workload scheduling and operational automation.

resource "aws_scheduler_schedule" "rds_start_daily" {
  name                         = "start-rds-daily-8-45-am-ist"
  group_name                   = "default"

  description                  = "Start RDS instance at 8:45 AM IST daily"

  schedule_expression          = "cron(45 8 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"

  # WHY:
  # Flexible time window is disabled to ensure the scheduler runs exactly at the configured business time.

  flexible_time_window {
    mode = "OFF"
  }

  # WHY:
  # Scheduler triggers the Lambda function responsible for starting the RDS instance.

  target {
    arn      = var.rds_start_lambda_arn
    role_arn = aws_iam_role.scheduler_role.arn

    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_identifier
    })
  }
}

# WHY:
# EventBridge Scheduler automatically stops the RDS instance after business hours.
# This reduces unnecessary infrastructure cost during idle nighttime periods.

resource "aws_scheduler_schedule" "rds_stop_daily" {
  name                         = "stop-rds-daily-9-00-pm-ist"
  group_name                   = "default"

  description                  = "Stop RDS instance at 9:00 PM IST daily"

  schedule_expression          = "cron(0 21 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"

  # WHY:
  # Ensures the stop operation executes exactly at the scheduled idle time.

  flexible_time_window {
    mode = "OFF"
  }

  # WHY:
  # Scheduler invokes the Lambda function responsible for stopping the RDS instance automatically.

  target {
    arn      = var.rds_stop_lambda_arn
    role_arn = aws_iam_role.scheduler_role.arn

    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_identifier
    })
  }
}