# WHY:
# Fetches details about the currently authenticated AWS account and IAM identity.
# Commonly used for dynamically referencing the AWS Account ID inside Terraform resources and policies.

data "aws_caller_identity" "current" {}

# WHY:
# Creates a ZIP package for the idle RDS Lambda function before deployment.
# Lambda functions must be packaged as ZIP archives for Terraform-based deployment.

data "archive_file" "rds_idle_stop_zip" {
  type        = "zip"
  source_file = "${path.module}/functions/rds_idle_stop.py"
  output_path = "${path.module}/functions/rds_idle_stop.zip"
}

# WHY:
# Packages the Lambda function responsible for scheduled RDS stop operations.
# This automation helps reduce infrastructure cost during non-business hours.

data "archive_file" "rds_stop_zip" {
  type        = "zip"
  source_file = "${path.module}/functions/rds_scheduler_stop.py"
  output_path = "${path.module}/functions/rds_scheduler_stop.zip"
}

# WHY:
# Packages the Lambda function responsible for scheduled RDS start operations.
# This ensures the database becomes available automatically before business hours begin.

data "archive_file" "rds_start_zip" {
  type        = "zip"
  source_file = "${path.module}/functions/rds_scheduler_start.py"
  output_path = "${path.module}/functions/rds_scheduler_start.zip"
}