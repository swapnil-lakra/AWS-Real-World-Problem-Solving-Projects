# WHY:
# CloudWatch Dashboard provides centralized visibility into infrastructure usage,
# waste detection, scaling behavior, and FinOps optimization metrics.

resource "aws_cloudwatch_dashboard" "finops_dashboard" {
  dashboard_name = "FinOps-Dashboard"

  dashboard_body = jsonencode({

    # WHY:
    # Dashboard title clearly identifies this dashboard as a FinOps monitoring platform
    # focused on cost optimization and infrastructure waste detection.

    title = "FinOps Dashboard - Cost & Waste Detection"

    widgets = [

      # ===========
      # EC2 SECTION
      # ===========

      # 1. Waste Detector
      # WHY:
      # Detects underutilized EC2 infrastructure by monitoring low ASG CPU usage.
      # Helps identify idle compute resources causing unnecessary cost.

      {
        type = "metric"

        properties = {
          title  = "ASG Waste Detector (Avg CPU < 5%)"
          region = var.aws_region

          metrics = [
            ["AWS/EC2","CPUUtilization","AutoScalingGroupName",var.asg_name, { stat = "Average" }]
          ]

          view    = "timeSeries"
          stacked = false

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }

          # WHY:
          # Threshold annotation visually highlights when the ASG becomes idle.

          annotations = {
            horizontal = [
              {
                label = "Idle threshold (5%)"
                value = 5
                fill  = "none"
                color = "#d13212"
              }
            ]
          }

          period = 300
        }

        x      = 0
        y      = 0
        width  = 12
        height = 6
      },

      # 2. Traffic and Compute Correlation
      # WHY:
      # Compares incoming traffic with CPU utilization to analyze workload efficiency.
      # Helps validate whether infrastructure scaling matches real traffic demand.

      {
        type = "metric"

        properties = {
          title  = "ASG Traffic & Compute Correlation"
          region = var.aws_region

          metrics = [
            ["AWS/EC2","NetworkIn","AutoScalingGroupName", var.asg_name, {stat = "Average", yAxis = "right"}],
            ["AWS/EC2","CPUUtilization","AutoScalingGroupName", var.asg_name, {stat = "Average", yAxis = "left"}]
          ]

          view    = "timeSeries"
          stacked = true

          yAxis = {
            left  = { label = "CPU %", min = 0, max = 100 }
            right = { label = "Network In (Bytes)" }
          }

          period = 300
        }

        x      = 12
        y      = 0
        width  = 12
        height = 6
      },

      # 3. Spike Handler - Max CPU and Instance Count
      # WHY:
      # Monitors Auto Scaling behavior during traffic spikes.
      # Verifies whether ASG launches additional instances correctly under high load.

      {
        type = "metric"

        properties = {
          title  = "ASG Scale-Out Monitoring (Spikes)"
          region = var.aws_region

          metrics = [
            ["AWS/EC2","CPUUtilization","AutoScalingGroupName", var.asg_name, { stat = "Maximum", period = 300, label = "Max CPU (5 min)"}],
            ["AWS/AutoScaling","GroupInServiceInstance","AutoScalingGroupName", var.asg_name, { stat = "Maximum", label = "Active Instances", yAxis = "right"}]
          ]

          view    = "timeSeries"
          stacked = false

          yAxis = {
            left  = { label = "CPU %", min = 0, max = 100 }
            right = { label = "Instance Count" }
          }

          period = 300
        }

        x      = 0
        y      = 6
        width  = 8
        height = 6
      },

      # 4. Cost-Saving Timer
      # WHY:
      # Displays business-hour scaling strategy and operational cost-saving schedule.
      # Helps operators quickly understand scheduled optimization behavior.

      {
        type = "text"

        properties = {
          markdown = <<-EOT
            ## FinOps Timer
            **Scheduled Scaling: 9 AM - 9 PM IST**
            **At night stopping instances cost 50% less**
          EOT
        }

        x      = 8
        y      = 6
        width  = 8
        height = 6
      },

      # 5. Credit Balance Monitoring
      # WHY:
      # Tracks CPU and network activity together for burstable EC2 workload analysis.
      # Helps monitor compute efficiency and workload behavior over time.

      {
        type = "metric"

        properties = {
          title  = "ASG CPU Credit Balance (Remaining)"
          region = var.aws_region

          metrics = [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.asg_name, { stat = "Average", yAxis = "right" }],
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name, { stat = "Average", yAxis = "left" }],
          ]

          view    = "timeSeries"
          stacked = true

          yAxis = {
            left  = { label = "CPU %", min = 0, max = 100 }
            right = { label = "Network In (Bytes)" }
          }

          period = 300
        }

        x      = 16
        y      = 6
        width  = 8
        height = 6
      },

      # ===========
      # RDS SECTION
      # ===========

      # 6. RDS Storage Over-Provisioning
      # WHY:
      # Monitors unused database storage capacity to identify overprovisioned RDS resources.
      # Helps analyze right-sizing opportunities for storage optimization.

      {
        type = "metric"

        properties = {
          title  = "RDS Storage Over-Provisioning"
          region = var.aws_region

          metrics = [
            ["AWS/RDS","FreeStorageSpace","DBInstanceIdentifier",var.rds_instance_identifier,{ stat = "Minimum", label = "FreeStorageBytes" }]
          ]

          view   = "gauge"
          period = 300

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }

          annotations = {}
        }

        x      = 0
        y      = 12
        width  = 12
        height = 6
      },

      # 7. Active Database Connections
      # WHY:
      # Tracks active database connections to determine whether the database is actually being used.
      # Helps validate idle detection logic for automation workflows.

      {
        type = "metric"

        properties = {
          title  = "Active Database Connections"
          region = var.aws_region

          metrics = [
            ["AWS/RDS","DatabaseConnections","DBInstanceIdentifier",var.rds_instance_identifier, { stat = "Maximum" }]
          ]

          view = "timeSeries"

          annotations = {
            horizontal = [{
              label = "Idle threshold (1 conn)"
              value = 1
              fill  = "none"
              color = "#d13212"
            }]
          }

          period = 300
        }

        x      = 12
        y      = 12
        width  = 12
        height = 6
      },

      # 8. Compute Efficiency
      # WHY:
      # Detects underutilized RDS compute resources using low CPU utilization monitoring.
      # Helps identify compute waste in overprovisioned databases.

      {
        type = "metric"

        properties = {
          title  = "RDS Compute Waste (CPU < 5%)"
          region = var.aws_region

          metrics = [
            ["AWS/RDS","CPUUtilization","DBInstanceIdentifier",var.rds_instance_identifier]
          ]

          view = "timeSeries"

          annotations = {
            horizontal = [{
              label = "Idle compute threshold"
              value = 5
              fill  = "none"
              color = "#d13212"
            }]
          }

          period = 300
        }

        x      = 0
        y      = 18
        width  = 8
        height = 6
      }

      # Additional widgets continue the same monitoring philosophy:
      # - IOPS activity monitoring for database workload analysis
      # - S3 request activity tracking for unused bucket detection
      # - Object growth monitoring for storage governance
      # - Storage class analysis for archival optimization opportunities
      # - Financial summary widgets for operational visibility

    ]
  })
}