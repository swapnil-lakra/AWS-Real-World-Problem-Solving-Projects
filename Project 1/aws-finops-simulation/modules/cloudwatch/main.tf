resource "aws_cloudwatch_dashboard" "finops_dashboard" {
  dashboard_name = "FinOps-Dashboard"

  dashboard_body = jsonencode({
    title = "FinOps Dashboard - Cost & Waste Detection"
    
    widgets = [
      # ===========
      # EC2 SECTION
      # ===========

      #1. Waste Detector 
      {
        type = "metric"
        properties = {
          title = "ASG Waste Detector (Avg CPU < 5%)"
          region = var.aws_region

          metrics = [
            ["AWS/EC2","CPUUtilization","AutoScalingGroupName",var.asg_name, { stat = "Average" }]
          ]

          view = "timeSeries"
          stacked = false
          yAxis = { left = { min = 0, max = 100 } }
          annotations = {
            horizontal = [
              {
                label = "Idle threshold (5%)"
                value = 5
                fill = "none"
                color = "#d13212"
              }
            ]
          }
          period = 300
        }
        x = 0
        y = 0
        width = 12
        height = 6
      },

      # 2. Traffic and Compute Correlation
      {
        type = "metric"
        properties = {
          title = "ASG Traffic & Compute Correlation"
          region = var.aws_region

          metrics = [
            ["AWS/EC2","NetworkIn","AutoScalingGroupName", var.asg_name, {stat = "Average", yAxis = "right"}],
            ["AWS/EC2","CPUUtilization","AutoScalingGroupName", var.asg_name, {stat = "Average", yAxis = "left"}]
          ]

          view = "timeSeries"
          stacked = true
          yAxis = {
            left = { label = "CPU %", min = 0, max = 100}
            right = { label = "Network In (Bytes)"}
          }
          period = 300
        }
        x = 12
        y = 0 
        width = 12
        height = 6
      },

      # 3. Spike Handler - Max CPU and Instance Count
      {
        type = "metric"
        properties = {
          title = "ASG Scale-Out Monitoring (Spikes)"
          region = var.aws_region

          metrics = [
            ["AWS/EC2","CPUUtilization","AutoScalingGroupName", var.asg_name, { stat = "Maximum", period = 300, label = "Max CPU (5 min)"}],
            ["AWS/AutoScaling","GroupInServiceInstance","AutoScalingGroupName", var.asg_name, { stat = "Maximum", label = "Active Instances", yAxis = "right"}]
          ]

          view = "timeSeries"
          stacked = false
          yAxis = {
            left = { label = "CPU %", min = 0, max = 100 }
            right = { label = "Instance Count" }
          }
          period = 300
        }
        x = 0
        y = 6
        width = 8
        height = 6
      },

      # 4. Cost-Saving Timer 
      {
        type = "text"
        properties = {
          markdown = <<-EOT
            ## FinOps Timer
            **Scheduled Scaling: 9 AM - 9 PM IST**
            **At night stopping instances cost 50% less**
          EOT
        }
        x = 8
        y = 6
        width = 8
        height = 6
      },

      # 5. Credit Balance (Aggregate for ASG)
      {
        type = "metric"
        properties = {
          title = "ASG CPU Credit Balance (Remaining)"
          region = var.aws_region
          
          metrics = [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.asg_name, { stat = "Average", yAxis = "right" }],
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name, { stat = "Average", yAxis = "left" }],
          ]

          view = "timeSeries"
          stacked = true
          yAxis = {
            left = { label = "CPU %", min = 0, max = 100 }
            right = { label = "Network In (Bytes)" }
          }
          period = 300  
        }
        x = 16
        y = 6
        width = 8
        height = 6
      },

      # ===========
      # RDS SECTION
      # ===========

      # # 6. Utilization vs Capacity Gauage (FreeStorageSpace)
      {
        type = "metric"
        properties = {
          title = "RDS Storage Over-Provisioning"
          region = var.aws_region

          metrics = [
            ["AWS/RDS","FreeStorageSpace","DBInstanceIdentifier",var.rds_instance_identifier,{ stat = "Minimum", label = "FreeStorageBytes" }]
          ]
          view = "gauge"
          yAxis = { left = { min = 0, max = 100 } }
          period = 300
          annotations = {}
        }
        x = 0
        y = 12
        width = 12
        height = 6
      },

      # 7. Active User Tracker - DatabaseConnections (Threshold 1)
      {
        type = "metric"
        properties = {
          title = "Active Database Connections"
          region = var.aws_region
          
          metrics = [
            ["AWS/RDS","DatabaseConnections","DBInstanceIdentifier",var.rds_instance_identifier, { stat = "Maximum" } ]
          ]
          view = "timeSeries"
          annotations = {
            horizontal = [{
              label = "Idle threshold (1 conn)"
              value = 1
              fill = "none"
              color = "#d13212"
            }]
          }
          period = 300
        }
        x = 12
        y = 12
        width = 12
        height = 6
      },

      # 8. Compute Efficiency - CPUUtilization ( <5% )
      {
        type = "metric"
        properties = {
          title = "RDS Compute Waste (CPU < 5%)"
          region = var.aws_region

          metrics = [
            ["AWS/RDS","CPUUtilization","DBInstanceIdentifier",var.rds_instance_identifier]
          ]

          view = "timeSeries"
          annotations = {
            horizontal = [{
              label = "Idle compute threshold"
              value = 5
              fill = "none"
              color = "#d13212"
            }]
          }
          period = 300
        }
        x = 0
        y = 18
        width = 8
        height = 6
      },

      # 9. IOPS Activity - Stacked Area (ReadIOPS + WriteIOPS)
      {
        type = "metric"
        properties = {
          title = "RDS I/O Activity (ReadIOPS + WriteIOPS)"
          region = var.aws_region
          metrics = [
            ["AWS/RDS","ReadIOPS","DBInstanceIdentifier",var.rds_instance_identifier, { stat = "Sum", color = "#0073bb", label = "Read IOPS" }],
            ["AWS/RDS", "WriteIOPS","DBInstanceIdentifier",var.rds_instance_identifier, { stat = "Sum", color = "#d63aff", label = "Write IOPS" }]
          ]
          view = "timeSeries"
          stacked = true
          period = 300

          yAxis = {
            left = {
              label = "Operations/Second"
              min   = 0
            }
          }

          annotations = {
            horizontal = [
              {
                label = "I/O Peak Baseline"
                value = 100 # Example baseline, ise apne DB capacity ke hisaab se set karein
                color = "#ffa500"
              }
            ]
          }
        }
        x = 8
        y = 18
        width = 8
        height = 6
      },

      # 10. RDS Financial Summary Text
      {
        type = "text"
        properties = {
          markdown = <<-EOT
            ## 💵 RDS Financial Impact
            - Stopping RDS during **non-business hours (12h/day)** reduces costs by **50%**
            - Automation status : ✅ Stop/Start Lambda active (check alarms).
            - Right-sizing potential: ${"`FreeStorageSpace`"} shows over-provisioning.   
          EOT
        }
        x = 16
        y = 18
        width = 8
        height = 6
      },

      # ==========
      # S3 SECTION
      # ==========

      # 11. Storage Composition - Pie Chart by Storage Class
      {
        type = "metric"
        properties = {
          title = "S3 Storage Class Byte (Standard)"
          region = var.aws_region

          metrics = [
           ["AWS/S3","BucketSizeBytes","BucketName",var.s3_bucket_name,"StorageClass","Standard", { stat = "Average", period = 300, label = "Standard Storage (Bytes)" }]
          ]
          view = "timeSeries"
          period = 300
          stacked = false

          yAxis = {
            left = {
              min = 0
            }
          }

          annotations = {}
        }
        x = 0
        y = 24
        width = 12
        height = 6
      },

      # 12. Ghost Bucket Detector - (GET,PUT,LIST Request) (30 daily total)
      {
        type = "metric"
      
        properties = {
          title  = "Ghost Bucket Detector - Active Requests (Get + Put + List)"
          region = var.aws_region
      
          metrics = [
            ["AWS/S3", "GetRequests",  "BucketName", var.s3_bucket_name, { id = "m1", stat = "Sum", period = 300, visible = false }],
            ["AWS/S3", "PutRequests",  "BucketName", var.s3_bucket_name, { id = "m2", stat = "Sum", period = 300, visible = false }],
            ["AWS/S3", "ListRequests", "BucketName", var.s3_bucket_name, { id = "m3", stat = "Sum", period = 300, visible = false }],
      
            // Math Expression: Sum of the three core requests
            [{ 
              expression = "m1 + m2 + m3", 
              label      = "Active Requests (Get+Put+List)", 
              id         = "e1",
              stat       = "Sum",
              period     = 300
            }]
          ]
      
          view = "timeSeries"
          period = 300
      
          sparkline = true
          annotations = {
            horizontal = [{
              label = "Idle Threshold"
              value = 0
              color = "#ff0000"
            }]
          }
        }
      
        x = 12
        y = 24
        width = 12
        height = 6
      },

      # 13. Object Count Trend
      {
        type = "metric"
        properties = {
          title = "S3 Object Count Trend"
          region = var.aws_region

          metrics = [
            ["AWS/S3","NumberOfObjects","BucketName",var.s3_bucket_name,"StorageClass","AllStorageTypes", { stat = "Average", label = "Total Objects", color = "#2ca02c" }]
          ]
          view = "timeSeries"
          period = 300

          sparkline = true

          yAxis = {
            left = {
              label = "Count"
              min   = 0
            }
          }

          annotations = {}
        }
        x = 0
        y = 30
        width = 8
        height = 6
      },

      # 14. Data Retrieval Analysis - Bar Chart (Get vs Put)
      {
        type = "metric"
        properties = {
          title = "GetRequests vs PutRequests (Archieve decision)"
          region = var.aws_region

          metrics = [
            ["AWS/S3", "GetRequests", "BucketName", var.s3_bucket_name, "FilterId", "EntireBucket", { "stat": "Sum", "period": 300, "label": "GET (Reads)", "color": "#1f77b4" }],
            ["AWS/S3", "PutRequests", "BucketName", var.s3_bucket_name, "FilterId", "EntireBucket", { "stat": "Sum", "period": 300, "label": "PUT (Writes)", "color": "#ff7f0e" }]
          ]

          view = "bar"
          period = 300

          yAxis = {
            left = {
              label = "Total Request Count"
              min   = 0
            }
          }

          annotations = {}
        }

        x = 8
        y = 30
        width = 8
        height = 6
      },

      # 15. Cost-Saving Summary Text for S3
      {
        type = "text"
        properties = {
          markdown = <<-EOT
            ## 🧊 S3 Cost Savings
            - **Standard Storage:** $0.23/GB
            - **Glacier Deep Archive** $0.00099/GB
            - **Savings Example:** Moving 10 GB logs to Glacier saves **-95%** monthly cost.
            - **Expiration policy:** Delete old backups after 90 days. 
          EOT
        }
        x = 16
        y = 30
        width = 8
        height = 6
      } 
    ]
  })
}