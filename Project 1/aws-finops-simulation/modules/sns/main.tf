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

# WHY:
# Email subscription is used to deliver SNS alerts directly to administrators or operators.
# This provides operational visibility for monitoring and automation events.

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.my_sns.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# WHY:
# SNS topic policy allows CloudWatch alarms to publish notifications to the SNS topic.
# It also restricts administrative access to the AWS account owner for better security control.

resource "aws_sns_topic_policy" "allow_cloudwatch" {
  arn = aws_sns_topic.my_sns.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "FirstStatementOwnerOnly"
        Effect = "Allow"

        Principal = {
          AWS = "*"
        }

        Action = [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ]

        Resource = aws_sns_topic.my_sns.arn

        Condition = {
          StringEquals = {
            "AWS:SourceOwner" = "598120810611"
          }
        }
      },
      {
        Sid    = "CloudWatchPublishPermission"
        Effect = "Allow"

        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }

        Action   = "SNS:Publish"
        Resource = aws_sns_topic.my_sns.arn
      }
    ]
  })
}