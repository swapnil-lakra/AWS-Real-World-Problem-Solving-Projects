output "aws_iam_lambda_role_arn" {
  description = "ARN of the IAM role assigned to Lambda functions for executing FinOps automation workflows."
  value       = aws_iam_role.lambda_finops_role.arn
}

output "aws_lambda_function_rds_idle_stop_arn" {
  description = "ARN of the Lambda function responsible for stopping idle RDS instances automatically."
  value       = aws_lambda_function.rds_idle_stop.arn
}

output "rds_stop_lambda_arn" {
  description = "ARN of the Lambda function used to stop the RDS instance based on scheduled automation."
  value       = aws_lambda_function.rds_stop_scheduler.arn
}

output "rds_start_lambda_arn" {
  description = "ARN of the Lambda function used to start the RDS instance during business hours automatically."
  value       = aws_lambda_function.rds_start_scheduler.arn
}