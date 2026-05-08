provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.env
      Project     = "aws-finops-simulation"
      Owner       = "swapnil"
      CostCenter  = "finops-labs"
      ManagedBy   = "terraform"
    }
  }
}