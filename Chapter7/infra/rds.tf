######################## VARIABLES ########################
variable "db_allocated_storage" {
  description = "DB Storage during allocation/creation"
  type        = number
}

variable "db_maximum_storage" {
  description = "DB Maximum Storage"
  type        = number
}

variable "db_engine" {
  description = "Database Engine"
  type        = string
}

variable "db_engine_family" {
  description = "Database Engine Family"
  type        = string
}

variable "db_engine_version" {
  description = "Database Engine Version"
  type        = string
}

variable "db_major_engine_version" {
  description = "Database Major Engine Version"
  type        = string
}

variable "db_instance_class" {
  description = "Database Instance class"
  type        = string
}

######################## MAIN ########################

module "pgsql" {

  source  = "terraform-aws-modules/rds/aws"
  version = "4.4.0"

  identifier                      = "${module.clustername.cluster_name}-pgsql"
  engine                          = var.db_engine
  engine_version                  = var.db_engine_version
  family                          = var.db_engine_family
  major_engine_version            = var.db_major_engine_version
  instance_class                  = var.db_instance_class
  allocated_storage               = 20
  max_allocated_storage           = 100
  storage_encrypted               = true
  db_name                         = var.db_name
  username                        = var.db_user_name
  create_random_password          = true
  random_password_length          = 16
  port                            = 5432
  multi_az                        = false
  subnet_ids                      = module.networking.db_subnets_id
  db_subnet_group_name            = module.networking.database_subnet_group_name
  vpc_security_group_ids          = [module.pgsql_sg_ingress.id]
  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  backup_retention_period         = 5
  skip_final_snapshot             = true
  deletion_protection             = false
  performance_insights_enabled    = false
  create_monitoring_role          = false
  parameters = [
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
  tags = {
    Name              = "${module.clustername.cluster_name}-rds-cluster"
    Environment       = var.environment
    terraform-managed = "true"

  }

  depends_on = [module.networking]
}


# Write the DB random password in SSM
module "ssmw-db-password" {
  source                = "./modules/ssmw"
  parameter_name        = "db_password"
  parameter_path        = "/${var.org_name}/database"
  parameter_value       = module.pgsql.db_instance_password
  parameter_description = "DB Password"
  clustername           = module.clustername.cluster_name
  parameter_type        = "SecureString"
  environment           = var.environment
}

# Write the DB end point URL in SSM
module "ssmw-db-endpoint" {
  source = "./modules/ssmw"

  parameter_name        = "db_endpoint_url"
  parameter_path        = "/${var.org_name}/database"
  parameter_value       = module.pgsql.db_instance_address
  parameter_description = "Endpoint URL of postgresql"
  clustername           = module.clustername.cluster_name
  parameter_type        = "String"
  environment           = var.environment
}

######################## OUTPUT ########################

