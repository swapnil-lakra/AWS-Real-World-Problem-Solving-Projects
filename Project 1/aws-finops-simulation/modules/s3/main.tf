resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "finops-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "finops-unused-storage-bucket"

    Role = "storage"
    Workload = "s3"
    Tier = "storage"

    Purpose = "cost-simulation"
    Scenario = "unused-storage"

    Utilization = "low"
    lifecycle = "not-configured"
    Optimization = "required"

    DataType = "logs"
    Access = "private"

    Criticality = "low"

    AutoDelete = "false"
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
    Name = "ec2-s3-access-role"
    Purpose = "ec2-to-s3-access"
    Workload = "iam"
    RoleType = "access-role"
    ManagedBy = "terraform"
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
    Name = "ec2-instance-profile"
    Purpose = "ec2-s3-access"
    Workload = "iam"
    ManagedBy = "terraform"
  }
}

# 4. S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [var.public_route_table_id, var.private_route_table_id]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}