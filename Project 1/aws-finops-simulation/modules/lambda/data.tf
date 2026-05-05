data "aws_caller_identity" "current" {}
data "archive_file" "rds_optimizer_zip" {
  type = "zip"
  source_file = "${path.module}/functions/rds_optimizer.py"
  output_path = "${path.module}/functions/rds_optimizer.zip"
}

data "archive_file" "s3_optimizer_zip" {
  type = "zip"
  source_file = "${path.module}/functions/s3_optimizer.py"
  output_path = "${path.module}/functions/s3_optimizer.zip"
}

data "archive_file" "rds_stop_zip" {
  type        = "zip"
  source_file = "${path.module}/functions/rds_scheduler_stop.py"
  output_path = "${path.module}/functions/rds_scheduler_stop.zip"
}

data "archive_file" "rds_start_zip" {
  type        = "zip"
  source_file = "${path.module}/functions/rds_scheduler_start.py"
  output_path = "${path.module}/functions/rds_scheduler_start.zip"
}
