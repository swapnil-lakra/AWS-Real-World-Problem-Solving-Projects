output "asg_sg_id" {
  value       = aws_security_group.asg_sg.id
  description = "ID of the security group attached to Auto Scaling Group instances for controlled application access."
}

output "rds_sg_id" {
  value       = aws_security_group.rds_sg.id
  description = "ID of the security group protecting the RDS database and allowing access only from application instances."
}

# output "alb_sg_id" {
#   value       = aws_security_group.alb_sg.id
#   description = "ID of the security group attached to the Application Load Balancer for internet-facing HTTP traffic."
# }