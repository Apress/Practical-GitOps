# Setting and locking the Dependencies to specific versions
terraform {
  required_providers {

    # AWS Cloud Provider
    aws = {
      source  = "hashicorp/aws"
      version = "4.10"
    }

  }
  # Setting the Terraform version
  required_version = ">= 1.1.0"
}

# Default provider accessing the root account
provider "aws" {
  # Any region can be set here as IAM is a global service
  region = var.region
}

# Provider configuration for Assuming Administrator Role in Identity account.
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${module.identity_account.id}:role/Administrator"
  }

  alias  = "identity"
  region = var.region
}

# Provider configuration for Assuming Administrator Role in Prod account.
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${module.prod_account.id}:role/Administrator"
  }

  alias  = "prod"
  region = var.region
}

# Provider configuration for Assuming Administrator Role in Staging account.
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${module.staging_account.id}:role/Administrator"
  }

  alias  = "staging"
  region = var.region
}

# Provider configuration for Assuming Administrator Role in Dev account.
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${module.dev_account.id}:role/Administrator"
  }

  alias  = "dev"
  region = var.region
}