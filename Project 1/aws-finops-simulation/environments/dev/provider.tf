# WHY:
# AWS provider configures Terraform to interact with AWS services in the specified region.
# It acts as the primary connection between Terraform and the AWS account.

provider "aws" {

  # WHY:
  # Region variable allows infrastructure deployment in different AWS regions without changing code.

  region = var.region

  # WHY:
  # default_tags automatically applies common tags to all supported AWS resources.
  # This improves cost tracking, governance, automation, and operational consistency.

  default_tags {
    tags = {

      # WHY:
      # Identifies the deployment environment for resource organization and filtering.

      Environment = "dev"

      # WHY:
      # Groups all infrastructure resources under the same project name for easier management.

      Project     = "aws-finops-simulation"

      # WHY:
      # Defines resource ownership for operational accountability.

      Owner       = "swapnil"

      # WHY:
      # Helps track infrastructure spending for FinOps and cost allocation reporting.

      CostCenter  = "finops-lab"

      # WHY:
      # Indicates that the infrastructure is fully managed through Infrastructure as Code.

      ManagedBy   = "terraform"

      # WHY:
      # Identifies the infrastructure as a simulation of a real-world SaaS environment.

      Organization = "mid-sized-saas-simulation"

      # WHY:
      # Describes the primary business objective of the infrastructure.

      Purpose      = "cost-optimization-simulation"

      # WHY:
      # Indicates the infrastructure follows FinOps governance and optimization practices.

      Compliance = "finops"

      # WHY:
      # Indicates monitoring and observability services are enabled across the infrastructure.

      Monitoring = "enabled"
    }
  }
}