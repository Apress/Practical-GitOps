# Setting and locking the Dependencies to specific versions
terraform {
  required_providers {

    # Provider to interact with kubernetes clusters
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.10.0"
    }

    # Provider to execute kubectl utility through terraform
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

  }
  # Setting the Terraform version
  required_version = ">= 1.1.0"
}
