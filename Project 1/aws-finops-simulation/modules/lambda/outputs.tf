output "aws_iam_lambda_role_arn" {
  description = "ARN of the IAM role for Lambda function"
  value = aws_iam_role.lambda_finops_role.arn
}

output "aws_lambda_function_rds_optimizer_arn" {
  description = "ARN of the RDS optimizer Lambda function"
  value = aws_lambda_function.rds_optimizer.arn
}

output "aws_lambda_function_s3_optimizer_arn" {
  description = "ARN of the S3 optimizer Lambda function"
  value = aws_lambda_function.s3_optimizer.arn
}

output "rds_stop_lambda_arn" {
  description = "ARN of RDS Stop Lambda function"
  value       = aws_lambda_function.rds_stop_scheduler.arn
}

output "rds_start_lambda_arn" {
  description = "ARN of RDS Start Lambda function"
  value       = aws_lambda_function.rds_start_scheduler.arn
}