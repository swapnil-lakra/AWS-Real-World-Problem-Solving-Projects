# EC2 Launch Template
# WHY:
# Launch Template standardizes EC2 instance configuration for Auto Scaling.
# It ensures all dynamically created instances use the same AMI, security groups, IAM role, and user data configuration.

resource "aws_launch_template" "lt" {
  name_prefix   = "web-lt-"
  image_id      = var.ami-id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }

  credit_specification {
    cpu_credits = "standard"
  }

  # block_device_mappings {
  #   device_name = "/dev/sda1"

  #   ebs {
  #     volume_size = 20
  #     volume_type = "gp3"

  #     delete_on_termination = true
  #   }
  # }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.asg_sg_id]
  }

  user_data = data.cloudinit_config.combined_scripts.rendered

  lifecycle {
    create_before_destroy = true
  }

  # WHY:
  # IMDSv2 is enforced for improved EC2 metadata security.
  # Hop limit is restricted to reduce metadata exposure risk.

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name         = "web-launch-template"
    Role         = "launch-template"
    Workload     = "asg"
    Tier         = "application"
    Purpose      = "web-server-deployment"
    Access       = "private"
    TrafficType  = "user-facing"
    Optimization = "enabled"
    Criticality  = "high"
  }
}

# Load Balancer Target Group
# WHY:
# Target Group registers ASG instances behind the ALB.
# Health checks ensure traffic is routed only to healthy application instances.

# resource "aws_lb_target_group" "tg" {
#   name     = "web-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id

#   health_check {
#     enabled             = true
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 5
#     interval            = 30
#     path                = "/"
#     port                = "traffic-port"
#   }

#   tags = {
#     Name         = "web-target-group"
#     Role         = "traffic-routing"
#     Workload     = "alb"
#     Tier         = "application"
#     Purpose      = "asg-traffic-routing"
#     TrafficType  = "http"
#     Monitoring   = "health-check-enabled"
#     Criticality  = "high"
#   }
# }

# ALB (Application Load Balancer)
# WHY:
# ALB acts as the public entry point for user traffic.
# It distributes requests across multiple ASG instances for scalability and availability.

# resource "aws_lb" "alb" {
#   name               = "web-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [var.alb_sg_id]
#   subnets            = var.public_subnet_ids

#   enable_deletion_protection = false

#   tags = {
#     Name         = "web-alb"
#     Role         = "load-balancer"
#     Workload     = "alb"
#     Tier         = "public"
#     Purpose      = "internet-ingress"
#     Access       = "internet-facing"
#     TrafficType  = "http"
#     Monitoring   = "enabled"
#     Optimization = "enabled"
#     Criticality  = "high"
#   }
# }

# Listener
# WHY:
# Listener accepts incoming HTTP traffic on port 80.
# It forwards requests from the ALB to the target group.

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg.arn
#   }

#   tags = {
#     Name         = "alb-http-listener"
#     Role         = "traffic-listener"
#     Workload     = "alb"
#     Tier         = "public"
#     Purpose      = "http-request-forwarding"
#     TrafficType  = "http"
#     Criticality  = "high"
#   }
# }

# Auto Scaling Group
# WHY:
# ASG automatically manages EC2 instance scaling based on workload demand.
# It improves availability while helping optimize infrastructure cost during low traffic periods.

resource "aws_autoscaling_group" "asg" {
  name                = "web-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  #target_group_arns         = [aws_lb_target_group.tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }

  # WHY:
  # Rolling refresh updates instances gradually without complete downtime.
  # This improves deployment reliability during infrastructure updates.

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
# WHY:
# Target tracking scaling automatically adjusts ASG capacity based on CPU utilization.
# This helps handle traffic spikes while reducing unnecessary compute cost.

resource "aws_autoscaling_policy" "cpu_tracking" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}

# Auto Scaling Schedule
# WHY:
# Scheduled scaling reduces infrastructure cost during non-business hours.
# ASG capacity is reduced to zero at night when traffic becomes idle.

resource "aws_autoscaling_schedule" "stop_night" {
  scheduled_action_name  = "stop-asg-night"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  min_size         = 0
  max_size         = 0
  desired_capacity = 0

  recurrence = "30 15 * * *"
}

# WHY:
# Scheduled startup restores application availability before business hours begin.
# This simulates predictable SaaS workload patterns.

resource "aws_autoscaling_schedule" "start_morning" {
  scheduled_action_name  = "start-asg-morning"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  recurrence = "15 3 * * *"
  time_zone  = "Asia/Kolkata"
}
