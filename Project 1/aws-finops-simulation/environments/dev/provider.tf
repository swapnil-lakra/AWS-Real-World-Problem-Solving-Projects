provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "aws-finops-simulation"
      Owner       = "swapnil"
      CostCenter  = "finops-lab"
      ManagedBy   = "terraform"

      Organization = "mid-sized-saas-simulation"
      Purpose      = "cost-optimization-simulation"

      Compliance = "finops"
      Monitoring = "enabled"
    }
  }
}