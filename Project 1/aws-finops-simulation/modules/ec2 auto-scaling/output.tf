output "asg_name" {
  description = "Name of the Auto Scaling Group managing dynamically scaled application instances."
  value       = aws_autoscaling_group.asg.name
}

# output "alb_dns_name" {
#   description = "Public DNS name of the Application Load Balancer used to access the web application."
#   value       = aws_lb.alb.dns_name
# }