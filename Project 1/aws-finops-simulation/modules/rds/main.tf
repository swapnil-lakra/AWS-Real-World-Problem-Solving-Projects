resource "aws_db_subnet_group" "db_net" {
  name = "main-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "web_server-db" {
  engine = var.engine_name
  instance_class = var.db_instance_classname
  engine_version = var.engine_version

  identifier = "database-1"

  username = data.aws_ssm_parameter.db_username.value
  password = data.aws_ssm_parameter.db_password.value
  port = "3306"
  skip_final_snapshot = true

  allocated_storage = 10
  storage_type = "gp2"
  
  # security group connection
  db_subnet_group_name = aws_db_subnet_group.db_net.name

  # subnet group connection
  vpc_security_group_ids = [var.rds_sg_id]

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