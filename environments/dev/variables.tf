variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment environment name used for infrastructure organization and resource tagging."
}

variable "region" {
  default     = "ap-south-1"
  type        = string
  description = "AWS region where the complete FinOps simulation infrastructure will be deployed."
}