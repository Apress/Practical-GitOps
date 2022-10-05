variable "oidc_url" {
  description = "OIDC URL"
  type        = string
}

variable "oidc_arn" {
  description = "OIDC ARN"
  type        = string
}

variable "k8s_sa_namespace" {
  description = "Namespace in which the Kubernetes resource is installed"
  type        = string
}

variable "k8s_irsa_name" {
  description = "Name of the service account"
  type        = string
}

variable "policy_arn" {
  description = "ARN Of the AWS Permissions Policy that needs to be applied"
  type        = string
}



