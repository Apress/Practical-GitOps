# Setting and locking the Dependencies to specific versions
terraform {
  required_providers {

    # AWS Cloud Provider
    aws = {
      source  = "hashicorp/aws"
      version = "4.10"
    }

    # Provider to interact with kubernetes clusters
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.10.0"
    }

    # Provider to interact with the local system
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

  }
  # Setting the Terraform version
  required_version = ">= 1.1.0"
}
