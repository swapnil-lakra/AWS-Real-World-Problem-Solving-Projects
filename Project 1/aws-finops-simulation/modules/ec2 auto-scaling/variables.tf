variable "ami-id" {
  default     = "ami-0aa31b568c1e8d622"
  type        = string
  description = "AMI ID used for launching EC2 instances inside the Auto Scaling Group."
}

variable "instance_type" {
  default     = "t3.micro"
  type        = string
  description = "EC2 instance type used for application workloads in the Auto Scaling Group."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the ALB and Auto Scaling infrastructure will be deployed."
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs used for deploying the internet-facing Application Load Balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used for deploying Auto Scaling Group application instances securely."
  type        = list(string)
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID attached to the Application Load Balancer for public HTTP access."
}

variable "asg_sg_id" {
  description = "Security group ID attached to Auto Scaling Group instances for controlled backend access."
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile attached to EC2 instances for secure AWS service access."
  type        = string
}

variable "website_directory" {
  default     = "/var/www/html"
  description = "Directory path where the website application files will be deployed on EC2 instances."
  type        = string
}

variable "github_repository" {
  default     = "https://github.com/Swapni-1/HubSpot-Homepage.git"
  description = "GitHub repository URL containing the static website source code used for deployment."
}