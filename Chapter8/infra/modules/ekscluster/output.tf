output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "cluster_role" {
  description = "Cluster role name"
  value       = module.eks.cluster_iam_role_name

}

output "cluster_certificate_authority_data" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC Issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM Role ARN"
  value       = module.eks.cluster_iam_role_arn
}

output "aws_auth_configmap_yaml" {
  description = "aws auth configmap"
  value       = module.eks.aws_auth_configmap_yaml
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

