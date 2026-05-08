# This module creates an IAM role and policy for the RDS start/stop scheduler.
resource "aws_iam_role" "scheduler_role" {
  name = "rds-s3-scheduler-role"

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

#Create a scheduler to start RDS instance at 8:45 AM ITC daily
resource "aws_scheduler_schedule" "rds_start_daily" {
  name = "start-rds-daily-8-45-am-ist"
  group_name = "default"
  description = "Start RDS instance at 8:45 AM IST daily"
  schedule_expression = "cron(45 8 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn = var.rds_start_lambda_arn
    role_arn = aws_iam_role.scheduler_role.arn
    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_identifier
    })
  }
}

# Create a scheduler to stop RDS instance at 9:00 PM ITC daily
resource "aws_scheduler_schedule" "rds_stop_daily" {
  name = "stop-rds-daily-9-00-pm-ist"
  group_name = "default"
  description = "Stop RDS instance at 9:00 PM IST daily"
  schedule_expression = "cron(0 21 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn = var.rds_stop_lambda_arn
    role_arn = aws_iam_role.scheduler_role.arn
    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_identifier
    })
  }
} 