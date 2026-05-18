# ============================================================================
# LAMBDA ROLE (shared by all optimization functions)
# ============================================================================

# WHY:
# IAM role allows Lambda functions to securely access AWS services required for automation.
# This centralizes permissions for all RDS optimization and scheduling workflows.

resource "aws_iam_role" "lambda_finops_role" {
  name = "lambda-finops-role"

  # WHY:
  # Trust policy allows AWS Lambda service to assume this IAM role.
  # Without this, Lambda functions cannot use the attached permissions.

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "lambda-finops-role"

    Role        = "lambda-execution-role"
    Workload    = "iam"
    Tier        = "automation"

    Purpose     = "rds-cost-optimization"

    Access      = "internal"

    Automation  = "enabled"

    Permissions = "rds-start-stop-sns-publish-tag-management"

    Criticality = "high"
  }
}

# ============================================================================
# CONSOLIDATED RDS START/STOP POLICY
# ============================================================================

# WHY:
# IAM policy grants Lambda functions permission to start, stop, describe,
# and manage tags for the RDS instance during automation workflows.

resource "aws_iam_role_policy" "rds_policy" {
  name = "rds-scheduler-policy"
  role = aws_iam_role.lambda_finops_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "RDSStartStop"
        Effect = "Allow"

        Action = [
          "rds:StartDBInstance",
          "rds:StopDBInstance",
          "rds:DescribeDBInstances"
        ]

        # WHY:
        # Restricts permissions only to the target RDS instance.
        # This follows least-privilege security principles.

        Resource = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${var.rds_instance_identifier}"
      },

      {
        Sid    = "RDSTagging"
        Effect = "Allow"

        Action = [
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource",
          "rds:ListTagsForResource"
        ]

        Resource = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${var.rds_instance_identifier}"
      },
      {
        Sid = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}
# WHY:
# Grants Lambda permission to publish operational notifications to SNS.
# Used for start, stop, success, and failure alerts.

resource "aws_iam_role_policy" "lambda_sns_policy" {
  name = "lambda-sns-publish-policy"
  role = aws_iam_role.lambda_finops_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "SNSPublishNotifications"
        Effect = "Allow"

        Action = [
          "SNS:Publish"
        ]

        Resource = var.sns_topic_arn
      }
    ]
  })
}

# WHY:
# Lambda function automatically starts the RDS instance before business hours.
# Helps simulate predictable SaaS workload scheduling behavior.

resource "aws_lambda_function" "rds_start_scheduler" {
  filename      = data.archive_file.rds_start_zip.output_path
  function_name = "rds-start-scheduler"

  role          = aws_iam_role.lambda_finops_role.arn

  handler       = "rds_scheduler_start.lambda_handler"
  runtime       = var.runtime_environment
  timeout       = 60

  # WHY:
  # source_code_hash ensures Lambda updates automatically when source code changes.

  source_code_hash = data.archive_file.rds_start_zip.output_base64sha256

  # WHY:
  # Environment variables provide runtime configuration without hardcoding values.

  environment {
    variables = {
      DB_INSTANCE_ID = var.rds_instance_identifier
      SNS_TOPIC_ARN  = var.sns_topic_arn
    }
  }

  tags = {
    Name        = "rds-start-scheduler"

    Role        = "scheduler"
    Workload    = "lambda"
    Tier        = "automation"

    Purpose     = "scheduled-rds-start"

    Automation  = "enabled"

    Schedule    = "08:45"

    Monitoring  = "sns-alert-enabled"

    Criticality = "high"
  }
}

# WHY:
# Lambda function automatically stops the RDS instance after business hours.
# Helps reduce unnecessary infrastructure cost during idle periods.

resource "aws_lambda_function" "rds_stop_scheduler" {
  filename      = data.archive_file.rds_stop_zip.output_path
  function_name = "rds-stop-scheduler"

  role          = aws_iam_role.lambda_finops_role.arn

  handler       = "rds_scheduler_stop.lambda_handler"
  runtime       = var.runtime_environment
  timeout       = 60

  source_code_hash = data.archive_file.rds_stop_zip.output_base64sha256

  environment {
    variables = {
      DB_INSTANCE_ID = var.rds_instance_identifier
      SNS_TOPIC_ARN  = var.sns_topic_arn
    }
  }

  tags = {
    Name        = "rds-stop-scheduler"

    Role        = "scheduler"
    Workload    = "lambda"
    Tier        = "automation"

    Purpose     = "scheduled-rds-stop"

    Automation  = "enabled"

    Schedule    = "21:00"

    Monitoring  = "sns-alert-enabled"

    Criticality = "high"
  }
}

# WHY:
# Lambda function handles automatic shutdown of idle RDS instances based on monitoring data.
# It is triggered only when intelligent idle detection conditions are satisfied.

resource "aws_lambda_function" "rds_idle_stop" {
  filename      = data.archive_file.rds_idle_stop_zip.output_path
  function_name = "rds-idle-stop"

  role          = aws_iam_role.lambda_finops_role.arn

  handler       = "rds_idle_stop.lambda_handler"
  runtime       = var.runtime_environment
  timeout       = 60

  source_code_hash = data.archive_file.rds_idle_stop_zip.output_base64sha256

  environment {
    variables = {
      DB_INSTANCE_ID = var.rds_instance_identifier
      SNS_TOPIC_ARN  = var.sns_topic_arn
    }
  }

  tags = {
    Name        = "rds-idle-optimizer"

    Role        = "cost-optimizer"
    Workload    = "lambda"
    Tier        = "automation"

    Purpose     = "idle-rds-optimization"

    Scenario    = "idle-database-detection"

    Monitoring  = "cloudwatch-enabled"
    Alerting    = "sns-enabled"

    Automation  = "enabled"

    IdlePolicy  = "cpu-less-than-5-and-dbconnections-equals-0-for-25min"

    Action      = "auto-stop-rds"

    Optimization = "enabled"
    Criticality  = "high"
  }
}

# WHY:
# Grants EventBridge Scheduler permission to invoke the RDS start Lambda function.
# Without this permission, scheduled automation cannot execute.

resource "aws_lambda_permission" "allow_scheduler_start" {
  statement_id  = "AllowSchedulerInvokeStartRDS"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_start_scheduler.function_name

  principal     = "scheduler.amazonaws.com"

  source_arn    = var.rds_start_rule_arn
}

# WHY:
# Grants EventBridge Scheduler permission to invoke the RDS stop Lambda function.
# Enables automated nightly database shutdown workflows.

resource "aws_lambda_permission" "allow_scheduler_stop" {
  statement_id  = "AllowSchedulerInvokeStopRDS"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_stop_scheduler.function_name

  principal     = "scheduler.amazonaws.com"

  source_arn    = var.rds_stop_rule_arn
}

# WHY:
# Grants EventBridge permission to invoke the idle optimization Lambda function.
# Enables event-driven automation when the RDS composite alarm enters ALARM state.

resource "aws_lambda_permission" "allow_eventbridge_scheduler_rds" {
  statement_id  = "AllowExecutionFromEventBridgeRDSIdle"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_idle_stop.function_name

  principal     = "events.amazonaws.com"

  source_arn    = var.rds_idle_rule_arn
}