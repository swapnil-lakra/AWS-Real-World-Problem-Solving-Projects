variable "rds_stop_lambda_arn" {
  description = "ARN of the Lambda function used for automated RDS stop scheduling operations."
  type        = string
}

variable "rds_start_lambda_arn" {
  description = "ARN of the Lambda function used for automated RDS start scheduling operations."
  type        = string
}

variable "rds_instance_identifier" {
  description = "Identifier of the RDS instance used in monitoring and automation workflows."
  type        = string
}

variable "rds_idle_lambda_function_arn" {
  description = "ARN of the Lambda function triggered to stop idle RDS instances automatically."
  type        = string
}