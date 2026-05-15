output "asg_name" {
  description = "Name of the Auto Scaling Group managing dynamically scaled application instances."
  value       = aws_autoscaling_group.asg.name
}
