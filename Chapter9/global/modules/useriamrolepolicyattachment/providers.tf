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