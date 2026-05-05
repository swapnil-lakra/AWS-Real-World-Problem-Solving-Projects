# 1. ALB Security Group

resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  description = "Allow HTTP Inbound"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "alb_ingress" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

# 2. WS_EC2 Security Group (ALB -> ASG)

resource "aws_security_group" "asg_sg" {
  name = "${var.project_name}-asg-sg"
  description = "Security group for ASG instances allowing HTTP only from ALB"
  vpc_id = var.vpc_id

  # Outbound: Everything is allowed
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-web-server-ec2"
    Role = "web-tier"
    Workload = "ec2"
    Access = "public"
    TrafficType = "http"
    Purpose = "web-server-access"
    AutoStop = "true"
    Schedule = "9-21"
    Criticality = "medium"
  }

}

resource "aws_security_group_rule" "asg_ingress_from_alb" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id = aws_security_group.asg_sg.id
}

# 2. RDS Security Group

resource "aws_security_group" "rds_sg" {
  name = "${var.project_name}-rds-sg"
  description = "Allow traffic from EC2 SG only"
  vpc_id = var.vpc_id

  # Outbound: Everything is allowed
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-rds"
    Role = "database-tier"
    Workload = "rds"
    Access = "private"
    TrafficType = "mysql"
    Purpose = "database-access"
    Utilization = "low"
    Rightsize = "pending"
    Criticality = "high"
  }
}

resource "aws_security_group_rule" "rds_ingress_from_asg" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = aws_security_group.asg_sg.id
  security_group_id = aws_security_group.rds_sg.id
}

