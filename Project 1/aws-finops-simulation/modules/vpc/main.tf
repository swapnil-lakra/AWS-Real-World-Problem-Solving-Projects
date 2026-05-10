# ===========|VPC|===============
# WHY:
# VPC creates an isolated network environment for securely hosting all infrastructure resources.
# DNS support and hostnames are enabled for internal communication and service discovery.

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "finops-vpc"
    Role    = "network"
    Purpose = "saas-infrastructure"
  }
}

# ============|Public Subnets|==============
# WHY:
# Public subnets are used for internet-facing components like the ALB.
# These subnets allow inbound traffic from external users.

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = "ap-south-2a"

  tags = {
    Name      = "public-subnet-1"
    Tier      = "public"
    Role      = "load-balancer-tier"
    Workload  = "alb"
    Access    = "internet-facing"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = "ap-south-2b"

  tags = {
    Name      = "public-subnet-2"
    Tier      = "public"
    Role      = "load-balancer-tier"
    Workload  = "alb"
    Access    = "internet-facing"
  }
}

# ============|Private Subnets|==============
# WHY:
# Private subnets are used for backend services like ASG instances and RDS databases.
# These resources are isolated from direct internet access for improved security.

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "ap-south-2a"

  tags = {
    Name      = "private-subnet-1"
    Tier      = "private"
    Role      = "application-database-tier"
    Workload  = "asg-rds"
    Access    = "internal"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "ap-south-2b"

  tags = {
    Name      = "private-subnet-2"
    Tier      = "private"
    Role      = "application-database-tier"
    Workload  = "asg-rds"
    Access    = "internal"
  }
}

# ============|Internet Gateway|============
# WHY:
# Internet Gateway enables internet connectivity for public subnet resources.
# It allows the ALB to receive external user traffic.

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name    = "finops-igw"
    Role    = "network-egress"
    Purpose = "internet-access"
  }
}

# ============| Public Route Table |============
# WHY:
# Public route table routes internet-bound traffic through the Internet Gateway.
# It enables public subnet resources to communicate externally.

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "public-route-table"
    Tier    = "public"
    Role    = "alb-routing"
    Purpose = "internet-routing"
  }
}

# =======| Public Route Table Associations |=============
# WHY:
# Associates public subnets with the public route table.
# This enables internet routing for ALB traffic.

resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# ===========|Private Route Table|===============
# WHY:
# Private route table is used for backend resources that should remain internal.
# It helps isolate ASG instances and RDS from direct internet exposure.

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name    = "private-route-table"
    Tier    = "private"
    Role    = "backend-routing"
    Purpose = "internal-routing"
  }
}

# ==========| Private Route Table Association |==========
# WHY:
# Associates private subnets with the private route table.
# This ensures backend resources follow internal routing rules.

resource "aws_route_table_association" "private_rta_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}