variable "engine_name" {
  default     = "mysql"
  type        = string
  description = "Database engine used for the RDS instance deployment."
}

variable "engine_version" {
  default     = "8.0"
  type        = string
  description = "Version of the database engine used for the RDS instance."
}

variable "db_instance_classname" {
  default     = "db.t3.micro"
  type        = string
  description = "Instance class defining the compute and memory capacity of the RDS database."
}

variable "db_username" {
  default     = "db_username"
  type        = string
  description = "Username used for authenticating access to the RDS database instance."
}

variable "db_password" {
  default     = "db_password"
  type        = string
  description = "Password used for secure authentication to the RDS database instance."
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used for deploying the RDS instance securely inside the VPC."
  type        = list(string)
}

variable "rds_sg_id" {
  default     = "ID of rds security group"
  description = "Security group ID attached to the RDS instance for controlled database access."
}