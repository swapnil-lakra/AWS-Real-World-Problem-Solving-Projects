# WHY:
# Terraform block defines the providers and versions required for the infrastructure project.
# This ensures consistent behavior and prevents unexpected compatibility issues.

terraform {

  required_providers {

    # WHY:
    # AWS provider is used to provision and manage AWS infrastructure resources.
    # Version pinning ensures stable and predictable deployments across environments.

    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }

    # WHY:
    # Archive provider is used to package Lambda source code into ZIP files before deployment.
    # Required for automating Lambda function packaging within Terraform.

    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
  }
}