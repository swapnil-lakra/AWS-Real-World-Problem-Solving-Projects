output "vpc_id" {
  value       = aws_vpc.my_vpc.id
  description = "ID of the VPC used to host the complete SaaS infrastructure environment."
}

output "public_subnet_1_id" {
  value       = aws_subnet.public_subnet_1.id
  description = "ID of the first public subnet used for internet-facing resources like the ALB."
}

output "public_subnet_2_id" {
  value       = aws_subnet.public_subnet_2.id
  description = "ID of the second public subnet used for high availability of public-facing resources."
}

output "private_subnet_1_id" {
  value       = aws_subnet.private_subnet_1.id
  description = "ID of the first private subnet hosting backend application and database resources."
}

output "private_subnet_2_id" {
  value       = aws_subnet.private_subnet_2.id
  description = "ID of the second private subnet used for backend high availability and workload distribution."
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "ID of the Internet Gateway enabling internet connectivity for public subnet resources."
}

output "public_route_table_id" {
  value       = aws_route_table.public_rt.id
  description = "ID of the public route table responsible for internet routing through the Internet Gateway."
}

output "private_route_table_id" {
  value       = aws_route_table.private_rt.id
  description = "ID of the private route table used for internal routing of backend resources."
}