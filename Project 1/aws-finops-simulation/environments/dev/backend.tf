# terraform {
#     backend "s3" {
#     bucket         = "finops-terraform-state-fa277"
#     key            = "global/mystatefile/terraform.tfstate"
#     region         = "ap-south-2"
#     dynamodb_table = "finops-terraform-state-lock"
#     encrypt        = true
#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# S3 Bucket for store terraform state and manage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "finops-terraform-state-fa277"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "terraform-state-bucket"

    Role        = "state-management"
    Workload    = "terraform"
    Tier        = "infrastructure-management"

    Purpose     = "terraform-remote-state"

    Access      = "private"

    Versioning  = "enabled"
    Encryption  = "enabled"

    Criticality = "high"

    BackupType  = "state-storage"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_crypto" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB Table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "finops-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-state-lock-table"

    Role        = "state-locking"
    Workload    = "terraform"
    Tier        = "infrastructure-management"

    Purpose     = "terraform-state-locking"

    Access      = "internal"

    Criticality = "high"

    Consistency = "state-protection"
  }
}