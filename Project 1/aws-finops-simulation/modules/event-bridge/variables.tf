variable "rds_stop_lambda_arn" {
  description = "arn value of rds stop lambda"
  type = string
}

variable "rds_start_lambda_arn" {
  description = "arn value of rds start lambda"
  type = string
}

variable "rds_instance_identifier" {
  description = "Value of RDS Instance Identifier"
  type = string
}

variable "rds_idle_lambda_function_arn" {
  description = "arn value of rds idle function"
  type = string
}