# WHY:
# DB Subnet Group defines which private subnets the RDS instance can use.
# This keeps the database isolated from direct internet access for better security.

resource "aws_db_subnet_group" "db_net" {
  name       = "main-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# WHY:
# RDS instance simulates an overprovisioned SaaS production database for FinOps optimization testing.
# It is monitored for low utilization and automated cost optimization workflows.

resource "aws_db_instance" "web_server-db" {
  engine               = var.engine_name
  instance_class       = var.db_instance_classname
  engine_version       = var.engine_version

  identifier           = "database-1"

  # WHY:
  # Database credentials are securely fetched from SSM Parameter Store instead of hardcoding secrets.
  # This improves security and secret management practices.

  username = data.aws_ssm_parameter.db_username.value
  password = data.aws_ssm_parameter.db_password.value

  port                 = "3306"

  # WHY:
  # Final snapshot is skipped to simplify testing and avoid extra storage cost in the simulation environment.

  skip_final_snapshot  = true

  allocated_storage    = 10
  storage_type         = "gp2"

  # WHY:
  # Associates the RDS instance with private subnets for secure backend-only access.

  db_subnet_group_name = aws_db_subnet_group.db_net.name

  # WHY:
  # Restricts database access only to authorized backend application resources using security groups.

  vpc_security_group_ids = [var.rds_sg_id]

  # WHY:
  # Tags help identify this RDS instance as an intentionally overprovisioned resource
  # used for monitoring, automation, governance, and cost optimization simulations.

  tags = {
    Name        = "overprovisioned-rds"

    Role        = "database-tier"
    Workload    = "rds"
    Tier        = "private"

    Purpose     = "cost-optimization-simulation"

    Access      = "internal"
    TrafficType = "mysql"

    Scenario    = "overprovisioned-database"

    Utilization = "low"
    Rightsize   = "pending"

    Monitoring  = "cloudwatch-enabled"
    Alerting    = "sns-enabled"

    Automation  = "enabled"

    AutoStop    = "true"
    StopTime    = "21-00"
    StartTime   = "08-45"

    IdlePolicy  = "cpu-less-than-5-and-dbconnections-equals-0-for-25min"

    Optimization = "required"
    Criticality  = "high"
  }
}