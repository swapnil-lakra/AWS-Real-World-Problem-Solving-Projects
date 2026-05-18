# WHY:
# Fetches information about the currently authenticated AWS account and IAM identity.
# Commonly used for dynamically referencing AWS Account ID, ARN, or user details inside Terraform configurations.

data "aws_caller_identity" "current" {}