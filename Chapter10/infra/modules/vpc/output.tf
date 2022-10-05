output "database_subnets_id" {
  value = module.vpc.database_subnets
}

output "database_subnet_group_id" {
  value = module.vpc.database_subnet_group
}

output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

output "public_subnets_id" {
  value = module.vpc.public_subnets
}

output "private_subnets_id" {
  value = module.vpc.private_subnets
}

output "db_subnets_id" {
  value = module.vpc.database_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}