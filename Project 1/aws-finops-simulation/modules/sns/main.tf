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

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.my_sns.arn
  protocol = "email"
  endpoint = var.alert_email
}

# sns topic policy

resource "aws_sns_topic_policy" "allow_cloudwatch" {
  arn = aws_sns_topic.my_sns.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid    = "FirstStatementOwnerOnly" # Unique ID for 1st statement
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
            Sid    = "CloudWatchPublishPermission" # Unique ID for 2nd statement
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