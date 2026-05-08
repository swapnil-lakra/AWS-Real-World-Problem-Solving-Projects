# Lambda IAM Role
# ============================================================================
# LAMBDA ROLE (shared by all optimization functions)
# ============================================================================
resource "aws_iam_role" "lambda_finops_role" {
  name = "lambda-finops-role"

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
# 1. CONSOLIDATED RDS START/STOP POLICY (No duplication!)
# ============================================================================
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
      }
    ]
  })
}

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

resource "aws_lambda_function" "rds_start_scheduler" {
  filename      = data.archive_file.rds_start_zip.output_path
  function_name = "rds-start-scheduler"
  role          = aws_iam_role.lambda_finops_role.arn
  handler       = "rds_scheduler_start.lambda_handler"
  runtime       = var.runtime_environment
  timeout       = 60

  source_code_hash = data.archive_file.rds_start_zip.output_base64sha256

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

resource "aws_lambda_function" "rds_idle_stop" {
  filename = data.archive_file.rds_idle_stop_zip.output_path
  function_name = "rds-idle-optimizer" 
  role = aws_iam_role.lambda_finops_role.arn
  handler = "rds_optimizer.lambda_handler"
  runtime = var.runtime_environment
  timeout = 60

  source_code_hash = data.archive_file.rds_idle_stop_zip.output_base64sha256

  environment {
    variables = {
      RDS_INSTANCE_ID = var.rds_instance_identifier
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


resource "aws_lambda_permission" "allow_scheduler_start" {
  statement_id  = "AllowSchedulerInvokeStartRDS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_start_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn = var.rds_start_rule_arn
}

resource "aws_lambda_permission" "allow_scheduler_stop" {
  statement_id  = "AllowSchedulerInvokeStopRDS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_stop_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn = var.rds_stop_rule_arn
}

#Lambda Permission for EventBridge Rule to invoke Lambda for RDS Idle
resource "aws_lambda_permission" "allow_eventbridge_scheduler_rds" {
  statement_id = "AllowExecutionFromEventBridgeRDSIdle"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_idle_stop.function_name
  principal = "events.amazonaws.com"
  source_arn = var.rds_idle_rule_arn
}