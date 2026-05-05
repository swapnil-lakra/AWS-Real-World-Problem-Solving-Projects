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
}

# ============================================================================
# 1. CONSOLIDATED RDS START/STOP POLICY (No duplication!)
# ============================================================================
resource "aws_iam_role_policy" "rds_scheduler_policy" {
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

# ============================================================================
# 2. RDS OPTIMIZER POLICY (with corrections)
# ============================================================================
resource "aws_iam_role_policy" "rds_optimizer_policy" {
  name = "rds-optimizer-policy"
  role = aws_iam_role.lambda_finops_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DescribeRDS"
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "StopAndTerminate"
        Effect = "Allow"
        Action = [
          "rds:StopDBInstance",
          "rds:DeleteDBInstance"
        ]
        Resource = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${var.rds_instance_identifier}"
      },
      {
        Sid    = "SnapshotManagement"
        Effect = "Allow"
        Action = [
          "rds:CreateDBSnapshot",
          "rds:DeleteDBSnapshot",
          "rds:DescribeDBSnapshots"
        ]
        Resource = [
          "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${var.rds_instance_identifier}",
          "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:snapshot:*"
        ]
      },
      {
        Sid    = "CloudWatchMetrics"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics"
        ]
        Resource = "*"  # CloudWatch doesn't support resource-level permissions
      },
      {
        Sid    = "Logging"
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

# ============================================================================
# 3. S3 OPTIMIZER POLICY (corrected)
# ============================================================================
resource "aws_iam_role_policy" "s3_optimizer_policy" {
  name = "s3-optimizer-policy"
  role = aws_iam_role.lambda_finops_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketMetadata"
        Effect = "Allow"
        Action = [
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}"
      },
      {
        Sid    = "CloudWatchActivity"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3DataCleaning"
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Sid    = "Logging"
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
}

resource "aws_lambda_function" "rds_optimizer" {
  filename = data.archive_file.rds_optimizer_zip.output_path
  function_name = "rds-idle-optimizer" 
  role = aws_iam_role.lambda_finops_role.arn
  handler = "rds_optimizer.lambda_handler"
  runtime = var.runtime_environment
  timeout = 60

  source_code_hash = data.archive_file.rds_optimizer_zip.output_base64sha256

  environment {
    variables = {
      RDS_INSTANCE_ID = var.rds_instance_identifier
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

resource "aws_lambda_function" "s3_optimizer" {
  filename = data.archive_file.s3_optimizer_zip.output_path
  function_name = "s3-activity-optimizer" 
  role = aws_iam_role.lambda_finops_role.arn
  handler = "s3_optimizer.lambda_handler"
  runtime = var.runtime_environment
  timeout = 60

  source_code_hash = data.archive_file.s3_optimizer_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET_NAME = var.s3_bucket_name
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

resource "aws_lambda_permission" "allow_scheduler_start" {
  statement_id  = "AllowSchedulerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_start_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn = var.rds_start_rule_arn
}

resource "aws_lambda_permission" "allow_scheduler_stop" {
  statement_id  = "AllowSchedulerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_stop_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn = var.rds_stop_rule_arn
}

#Lambda Permission for EventBridge Scheduler to invoke Lambda for S3 Optimizer
resource "aws_lambda_permission" "allow_eventbridge_scheduler_rds" {
  statement_id = "AllowExecutionFromEventBridgeSchedulerRDS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_optimizer.function_name
  principal = "scheduler.amazonaws.com"
  source_arn = var.rds_idle_scheduler_rule_arn
}
# Lambda Permission for EventBridge Scheduler to invoke Lambda for S3 Optimizer
resource "aws_lambda_permission" "allow_eventbridge_scheduler_s3" {
  statement_id = "AllowExecutionFromEventBridgeSchedulerS3"
  action = "lambda:InvokeFunction"    
  function_name = aws_lambda_function.s3_optimizer.function_name  
  principal = "scheduler.amazonaws.com"  
  source_arn = var.s3_unused_scheduler_rule_arn
} 