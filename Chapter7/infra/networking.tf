######################## VARIABLES ########################

data "aws_availability_zones" "availability_zones" {}

variable "database_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  type        = string
}

######################## MAIN ########################

# Create a cluster name specific to the environment,region and organisation name for uniqueness.
module "clustername" {
  source = "./modules/clustername"

  environment = var.environment
  region      = var.region
  org_name    = var.org_name
}

# Crate a VPC with all the associated network plumbing
module "networking" {
  source = "./modules/vpc"

  clustername           = module.clustername.cluster_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_cidr  = var.private_subnets_cidr
  database_subnets_cidr = var.database_subnets_cidr
  region                = var.region
  availability_zones    = data.aws_availability_zones.availability_zones.names

  depends_on = [module.clustername]
}

# PGSQL Ingress Security Group Module
module "pgsql_sg_ingress" {
  source = "./modules/securitygroup"

  sg_name        = "pgsql_sg_ingress"
  sg_description = "Allow Port 5432 from within the VPC"
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  type           = "ingress"
  from_port      = 5432
  to_port        = 5432
  protocol       = "tcp"
  cidr_blocks    = [var.vpc_cidr]

  depends_on = [module.networking]
}

# Generic Egress Security Group Module
module "generic_sg_egress" {
  source = "./modules/securitygroup"

  sg_name        = "generic_sg_egress"
  sg_description = "Allow servers to connect to outbound internet"
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  type           = "egress"
  from_port      = 0
  to_port        = 65535
  protocol       = "tcp"
  cidr_blocks    = ["0.0.0.0/0"]

  depends_on = [module.networking]
}

######################## OUTPUTS ########################