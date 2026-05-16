# WHY:
# SNS topic is used as the central notification service for infrastructure alerts and automation events.
# It sends alerts for idle resources, traffic spikes, and operational monitoring events.

resource "aws_sns_topic" "my_sns" {
  name = var.sns_topic_name

  tags = {
    Name        = "finops-alert-topic"

    Role        = "notification-service"
    Workload    = "sns"
    Tier        = "monitoring"

    Purpose     = "cost-optimization-alerts"
    AlertType   = "budget-spike-idle-resource"

    Access      = "internal"
    Criticality = "high"

    Automation  = "enabled"
  }
}

# SNS Email Subscription
# WHY:
# Subscribes an email endpoint to receive real-time infrastructure alerts,
# operational notifications, and automation event updates.

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.my_sns.arn
  protocol  = "email"
  endpoint  = data.aws_ssm_parameter.sns_topic_email.value
}

# SNS Topic Policy
# WHY:
# Defines secure publish permissions so only approved AWS services
# can send operational alerts and automation notifications to the SNS topic.

resource "aws_sns_topic_policy" "allow_cloudwatch" {
  arn = aws_sns_topic.my_sns.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. CloudWatch Alarm Publish Permission
      # WHY:
      # Allows CloudWatch alarms to securely publish monitoring alerts
      # for infrastructure health, utilization, and optimization events.
      {
        Sid    = "CloudWatchPublishPermission"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.my_sns.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cloudwatch:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
      },
      
      # 2. S3 Event Publish Permission
      # WHY:
      # Allows the S3 bucket to publish object deletion notifications
      # for storage monitoring and operational visibility.
      {
        Sid    = "S3PublishPermission"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.my_sns.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = var.s3_bucket_arn
          }
        }
      },
      
      # 3. EventBridge Publish Permission
      # WHY:
      # Allows EventBridge rules to send scheduled Auto Scaling
      # operational events and automation notifications to SNS.
      {
        Sid    = "EventBridgePublishPermission"
        Effect = "Allow"
        Principal = { 
          Service = "events.amazonaws.com" 
        }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.my_sns.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:events:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:rule/*"
          }
        }
      }
    ]
  })
}