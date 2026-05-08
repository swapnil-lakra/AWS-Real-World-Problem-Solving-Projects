resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "finops-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "finops-storage-bucket"

    Role        = "storage"
    Workload    = "s3"
    Tier        = "storage"

    Purpose     = "application-storage"

    Access      = "private"
    DataType    = "application-assets"

    Lifecycle   = "enabled"
    Encryption  = "enabled"
    Monitoring  = "cloudwatch-metrics"

    Optimization = "enabled"
    Criticality  = "medium"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.bucket

  rule {
    id = "delete-objects-after-30-days"
    status = "Enabled"

    expiration {
      days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
  

}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.my_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
}

resource "aws_s3_bucket_metric" "entire_bucket" {
  bucket = aws_s3_bucket.my_bucket.bucket
  name = "EntireBucket"
}

#1 IAM Role
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "ec2-s3-access-role"

    Role        = "iam-role"
    Workload    = "iam"

    Purpose     = "asg-s3-access"

    Access      = "private-instance-access"

    Criticality = "high"
  }
}

#2. EC2 Access Policy
resource "aws_iam_role_policy" "s3_policy" {
  name = "ec2_s3_policy"
  role = aws_iam_role.ec2_s3_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.my_bucket.arn,
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  })

}

# 3. Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.bucket_name
  role = aws_iam_role.ec2_s3_access_role.name

  tags = {
    Name        = "asg-instance-profile"

    Role        = "instance-profile"
    Workload    = "asg"

    Purpose     = "private-instance-s3-access"

    Access      = "internal"

    Criticality = "high"
  }
}

# 4. S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [var.public_route_table_id, var.private_route_table_id]

  tags = {
    Name        = "s3-gateway-endpoint"

    Role        = "network-endpoint"
    Workload    = "s3-access"

    Purpose     = "private-subnet-s3-connectivity"

    Access      = "internal"

    TrafficType = "s3"

    Criticality = "high"
  }
}