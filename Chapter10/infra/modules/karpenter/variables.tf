variable "node_group_role_arn" {
  description = "NodeGroup Role ARN"
  type        = string
}

variable "eks_cluster_id" {
  description = "EKS Cluster ID"
  type        = string
}

variable "karpenter_version" {
  description = "Karpenter Version"
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

variable "eks_cluster_endpoint_url" {
  description = "EKS Cluster Endpoint URL"
  type        = string
}



