variable "vpc_id" {
  description = "VPC ID used to associate security groups and networking resources within the infrastructure."
  type        = string
}

variable "project_name" {
  default     = "finops"
  type        = string
  description = "Project name used for consistent resource naming and infrastructure identification."
}