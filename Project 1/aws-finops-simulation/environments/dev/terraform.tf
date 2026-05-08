terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
  }
  

  backend "s3" {
    bucket = aws_s3_bucket.terraform_state.bucket
    key    = "global/mystatefile/terraform.tfstate"
    region = var.region
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
    encrypt = true
  }
}