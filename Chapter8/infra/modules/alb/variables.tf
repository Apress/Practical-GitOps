variable "environment" {
  description = "The Deployment environment"
  type        = string
}

variable "clustername" {
  description = "Cluster Name"
  type        = string
}

variable "oidc_url" {
  description = "OIDC URL"
  type        = string
}

variable "oidc_arn" {
  description = "OIDC ARN"
  type        = string
}

variable "awslb_version" {
  description = "AWS Helm Chart Version"
  type        = string
}