# EC2 Launch Template
resource "aws_launch_template" "lt" {
  name_prefix = "web-lt-"
  image_id = var.ami-id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.asg_sg_id]
  }

  user_data = data.cloudinit_config.combined_scripts.rendered

  lifecycle {
    create_before_destroy = true
  }

  metadata_options {
    http_tokens = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name        = "web-launch-template"

    Role        = "launch-template"
    Workload    = "asg"
    Tier        = "application"

    Purpose     = "web-server-deployment"

    Access      = "private"

    TrafficType = "user-facing"

    Optimization = "enabled"
    Criticality  = "high"
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "tg" {
  name = "web-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    path = "/"
    port = "traffic-port"
  }

  tags = {
    Name        = "web-target-group"

    Role        = "traffic-routing"
    Workload    = "alb"
    Tier        = "application"

    Purpose     = "asg-traffic-routing"

    TrafficType = "http"

    Monitoring  = "health-check-enabled"

    Criticality = "high"
  }
}

# ALB (Application Load Balancer)
resource "aws_lb" "alb" {
  name = "web-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [var.alb_sg_id]
  subnets = var.public_subnet_ids 

  enable_deletion_protection = false

  tags = {
    Name        = "web-alb"

    Role        = "load-balancer"
    Workload    = "alb"
    Tier        = "public"

    Purpose     = "internet-ingress"

    Access      = "internet-facing"
    TrafficType = "http"

    Monitoring  = "enabled"

    Optimization = "enabled"
    Criticality  = "high"
  }
}

# Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = {
    Name        = "alb-http-listener"

    Role        = "traffic-listener"
    Workload    = "alb"
    Tier        = "public"

    Purpose     = "http-request-forwarding"

    TrafficType = "http"

    Criticality = "high"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name = "web-asg"
  desired_capacity = 1
  min_size = 1
  max_size = 2
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
  health_check_type = "ELB"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
    #ignore_changes = [desired_capacity]
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "web-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "application-tier"
    propagate_at_launch = true
  }

  tag {
    key                 = "Workload"
    value               = "asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "private"
    propagate_at_launch = true
  }

  tag {
    key                 = "Purpose"
    value               = "cost-optimization-simulation"
    propagate_at_launch = true
  }

  tag {
    key                 = "TrafficPattern"
    value               = "predictable-with-spikes"
    propagate_at_launch = true
  }

  tag {
    key                 = "Schedule"
    value               = "08:45-21:00"
    propagate_at_launch = true
  }

  tag {
    key                 = "AutoScaling"
    value               = "enabled"
    propagate_at_launch = true
  }

  tag {
    key                 = "Optimization"
    value               = "enabled"
    propagate_at_launch = true
  }

  tag {
    key                 = "Criticality"
    value               = "high"
    propagate_at_launch = true
  }
}

# Scaling Policies
resource "aws_autoscaling_policy" "cpu_tracking" {
  name = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}

# Auto Scaling Schedule
resource "aws_autoscaling_schedule" "stop_night" {
  scheduled_action_name = "stop-asg-night"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  
  min_size = 0
  max_size = 0
  desired_capacity = 0

  recurrence = "30 15 * * *" # 9:00 PM IST (3:30 PM UTC)
}

resource "aws_autoscaling_schedule" "start_morning" {
  scheduled_action_name = "start-asg-morning"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  
  min_size = 1
  max_size = 2
  desired_capacity = 1

  recurrence = "15 3 * * *" # 8:45 AM IST (3:15 UTC)
  time_zone = "Asia/Kolkata"
}
