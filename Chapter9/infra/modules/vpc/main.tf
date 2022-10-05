# Create a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  name                         = "${var.clustername}-vpc"
  cidr                         = var.vpc_cidr
  enable_dns_hostnames         = true
  enable_dns_support           = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_vpn_gateway           = var.enable_vpn_gateway
  azs                          = var.availability_zones
  private_subnets              = var.private_subnets_cidr
  public_subnets               = var.public_subnets_cidr
  database_subnets             = var.database_subnets_cidr
  create_database_subnet_group = true

  tags = {
    "kubernetes.io/cluster/${var.clustername}" = "shared"
    "Name"                                     = "${var.clustername}-vpc"
    "Environment"                              = var.environment
    terraform-managed                          = "true"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.clustername}" = "shared"
    "kubernetes.io/role/elb"                   = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.clustername}" = "shared"
    "kubernetes.io/role/internal-elb"          = "1"
  }
}