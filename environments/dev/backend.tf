
# WHY:
# Local backend stores the Terraform state file on the local machine instead of remote storage.
# Commonly used for learning, testing, and small environments before migrating to remote state management.

terraform {

  backend "local" {

    # WHY:
    # Defines the local file path where Terraform state will be stored and managed.

    path = "terraform.tfstate"
  }
}

# WHY:
# Terraform remote backend stores infrastructure state centrally in S3.
# This prevents local state loss and enables consistent infrastructure management.

# terraform {
#   backend "s3" {
#
#     # WHY:
#     # S3 bucket stores the Terraform state file securely and centrally.
#
#     bucket = "finops-terraform-state-fa277"
#
#     # WHY:
#     # Key defines the path/location of the Terraform state file inside the bucket.
#
#     key = "global/mystatefile/terraform.tfstate"
#
#     # WHY:
#     # Specifies the AWS region where the backend resources are hosted.
#
#     region = "ap-south-2"
#
#     # WHY:
#     # DynamoDB table provides Terraform state locking to prevent concurrent modifications.
#
#     dynamodb_table = "finops-terraform-state-lock"
#
#     # WHY:
#     # Enables encryption for protecting sensitive Terraform state data at rest.
#
#     encrypt = true
#   }
# }

# ============================================================================
# TERRAFORM STATE S3 BUCKET
# ============================================================================

# WHY:
# S3 bucket stores Terraform state files securely for centralized infrastructure management.
# Remote state improves collaboration, consistency, and disaster recovery.

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "finops-terraform-state-fa277"

#   # WHY:
#   # prevent_destroy is disabled to allow cleanup in temporary lab or simulation environments.
#
#   lifecycle {
#     prevent_destroy = false
#   }

#   tags = {
#     Name        = "terraform-state-bucket"

#     Role        = "state-management"
#     Workload    = "terraform"
#     Tier        = "infrastructure-management"

#     Purpose     = "terraform-remote-state"

#     Access      = "private"

#     Versioning  = "enabled"
#     Encryption  = "enabled"

#     Criticality = "high"

#     BackupType  = "state-storage"
#   }
# }

# WHY:
# Enables versioning for Terraform state files.
# Helps recover previous state versions if corruption or accidental deletion occurs.

# resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
#   bucket = aws_s3_bucket.terraform_state.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# WHY:
# Enables server-side encryption for protecting Terraform state data stored in S3.
# Terraform state may contain sensitive infrastructure information and secrets.

# resource "aws_s3_bucket_server_side_encryption_configuration" "state_crypto" {
#   bucket = aws_s3_bucket.terraform_state.id
#
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# ============================================================================
# TERRAFORM STATE LOCKING
# ============================================================================

# WHY:
# DynamoDB table provides state locking for Terraform operations.
# This prevents multiple users or pipelines from modifying infrastructure simultaneously.

# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name         = "finops-terraform-state-lock"
#
#   billing_mode = "PAY_PER_REQUEST"
#
#   # WHY:
#   # LockID uniquely identifies active Terraform state locks.
#
#   hash_key = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Name        = "terraform-state-lock-table"

#     Role        = "state-locking"
#     Workload    = "terraform"
#     Tier        = "infrastructure-management"

#     Purpose     = "terraform-state-locking"

#     Access      = "internal"

#     Criticality = "high"

#     Consistency = "state-protection"
#   }
# }