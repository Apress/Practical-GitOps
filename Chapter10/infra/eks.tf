######################## VARIABLES ########################

variable "eks_version" {
  description = "EKS Version"
  type        = string
}

variable "instance_types" {
  description = "Instance Types for deploying k8s environment"
  type        = list(string)
}

variable "alb_s3_bucket" {
  description = "Name of the S3 Bucket storing ALB Logs"
  type        = string
}

######################## MAIN ########################

module "eks_kms" {
  source = "./modules/awskms"

  environment             = var.environment
  description             = "KMS Key to encrypt secrets in the Cluster"
  kms_alias               = "eks1"
  deletion_window_in_days = 7

}
# Main module that creates the master plane components
module "eks" {
  source = "./modules/ekscluster"

  clustername     = module.clustername.cluster_name
  eks_version     = var.eks_version
  private_subnets = module.networking.private_subnets_id
  vpc_id          = module.networking.vpc_id
  environment     = var.environment
  kms_key_arn     = module.eks_kms.key_arn
  instance_types  = var.instance_types

}

# Module that creates the Application Load Balancer for use as an Ingress Controller
module "alb_ingress" {
  source = "./modules/alb"

  clustername   = module.clustername.cluster_name
  oidc_url      = module.eks.cluster_oidc_issuer_url
  oidc_arn      = module.eks.oidc_provider_arn
  awslb_version = "1.4.1"
  environment   = var.environment
  kms_key_arn   = module.eks_kms.key_arn
  alb_s3_bucket = var.alb_s3_bucket

  depends_on = [module.eks, module.networking]
}

module "karpenter" {
  source = "./modules/karpenter"

  node_group_role_arn      = module.eks.eks_managed_node_groups["app"].iam_role_name
  eks_cluster_id           = module.eks.cluster_id
  eks_cluster_endpoint_url = module.eks.cluster_endpoint
  oidc_url                 = module.eks.cluster_oidc_issuer_url
  oidc_arn                 = module.eks.oidc_provider_arn
  karpenter_version        = "v0.6.0"

  depends_on = [module.eks, module.networking]
}

######################## Outputs ########################

output "cluster_name" {
  value = module.clustername.cluster_name
}

output "region" {
  value = var.region
}