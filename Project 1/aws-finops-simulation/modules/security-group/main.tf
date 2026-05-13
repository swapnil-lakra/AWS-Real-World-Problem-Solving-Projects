# 1. ALB Security Group
# WHY:
# This security group allows external users to access the Application Load Balancer over HTTP.
# Outbound traffic is allowed so the ALB can communicate with backend application instances.

# resource "aws_security_group" "alb_sg" {
#   name        = "alb-sg"
#   description = "Allow HTTP Inbound"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "sg-alb"

#     Role        = "load-balancer"
#     Workload    = "alb"
#     Tier        = "public"

#     Access      = "internet-facing"
#     TrafficType = "http"

#     Purpose     = "public-ingress"

#     Criticality = "high"
#   }
# }

# WHY:
# Allows inbound HTTP traffic from the internet to the ALB.
# This enables users to access the web application publicly.

# resource "aws_security_group_rule" "alb_ingress" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.alb_sg.id
# }

# 2. ASG Security Group (ALB -> ASG)
# WHY:
# This security group protects application instances inside the private subnet.
# Only the ALB is allowed to communicate with ASG instances over HTTP.

resource "aws_security_group" "asg_sg" {
  name        = "${var.project_name}-asg-sg"
  description = "Security group for ASG instances allowing HTTP only from ALB"
  vpc_id      = var.vpc_id

  # Outbound: Everything is allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-asg"

    Role        = "application-tier"
    Workload    = "asg"
    Tier        = "private"

    Access      = "internal"
    TrafficType = "web-traffic"

    Purpose     = "application-access"

    TrafficPattern = "predictable-with-spikes"

    Optimization = "required"
    Criticality  = "high"
  }
}

# WHY:
# Allows HTTP traffic only from the ALB security group.
# This prevents direct internet access to private ASG instances.

resource "aws_security_group_rule" "asg_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.asg_sg.id
}

# 3. RDS Security Group
# WHY:
# This security group secures the database layer inside the private subnet.
# Only backend application instances are allowed to connect to the database.

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow traffic from EC2 SG only"
  vpc_id      = var.vpc_id

  # Outbound: Everything is allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-rds"

    Role        = "database-tier"
    Workload    = "rds"
    Tier        = "private"

    Access      = "internal"
    TrafficType = "mysql"

    Purpose     = "database-access"

    Scenario     = "overprovisioned-database"
    Utilization  = "low"
    Rightsize    = "pending"

    Optimization = "required"
    Criticality  = "high"
  }
}

# WHY:
# Allows MySQL traffic only from the ASG security group.
# This restricts database access to authorized application instances only.

resource "aws_security_group_rule" "rds_ingress_from_asg" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}