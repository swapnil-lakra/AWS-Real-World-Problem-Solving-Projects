output "aws_iam_lambda_role_arn" {
  description = "ARN of the IAM role for Lambda function"
  value = aws_iam_role.lambda_finops_role.arn
}

output "aws_lambda_function_rds_idle_stop_arn" {
  description = "ARN of the RDS idle function Lambda function"
  value = aws_lambda_function.rds_idle_stop.arn
}

output "rds_stop_lambda_arn" {
  description = "ARN of RDS Stop Lambda function"
  value       = aws_lambda_function.rds_stop_scheduler.arn
}

output "rds_start_lambda_arn" {
  description = "ARN of RDS Start Lambda function"
  value       = aws_lambda_function.rds_start_scheduler.arn
}