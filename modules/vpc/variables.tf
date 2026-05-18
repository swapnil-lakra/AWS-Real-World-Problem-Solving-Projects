variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block used to define the overall network range for the VPC."
}

variable "private_subnet_1_cidr" {
  default     = "10.0.1.0/24"
  type        = string
  description = "CIDR block for the first private subnet used by backend resources like ASG and RDS."
}

variable "private_subnet_2_cidr" {
  default     = "10.0.3.0/24"
  type        = string
  description = "CIDR block for the second private subnet used for high availability of backend workloads."
}

variable "public_subnet_1_cidr" {
  default     = "10.0.2.0/24"
  type        = string
  description = "CIDR block for the first public subnet hosting internet-facing resources like the ALB."
}

variable "public_subnet_2_cidr" {
  default     = "10.0.4.0/24"
  type        = string
  description = "CIDR block for the second public subnet used for high availability of public-facing services."
}