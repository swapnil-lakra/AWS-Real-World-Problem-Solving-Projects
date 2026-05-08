data "aws_caller_identity" "current" {}
data "archive_file" "rds_idle_stop_zip" {
  type = "zip"
  source_file = "${path.module}/functions/rds_idle_stop.py"
  output_path = "${path.module}/functions/rds_idle_stop.zip"
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
