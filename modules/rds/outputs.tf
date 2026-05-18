output "db_instance_id" {
  value       = aws_db_instance.web_server-db.id
  description = "Unique ID of the RDS database instance created for the FinOps simulation environment."
}

output "db_instance_identifier" {
  value       = aws_db_instance.web_server-db.identifier
  description = "Identifier name of the RDS instance used for monitoring, automation, and management operations."
}

output "db_endpoint" {
  value       = aws_db_instance.web_server-db.endpoint
  description = "Connection endpoint of the RDS database used by backend application instances."
}

output "db_port" {
  value       = aws_db_instance.web_server-db.port
  description = "Port number exposed by the RDS database for application connectivity."
}