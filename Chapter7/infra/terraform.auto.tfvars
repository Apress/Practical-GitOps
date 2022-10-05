/********** Networking Module ***************/
vpc_cidr = "10.0.0.0/16"

public_subnets_cidr = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnets_cidr = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24"
]

database_subnets_cidr = [
  "10.0.21.0/24",
  "10.0.22.0/24",
  "10.0.23.0/24"
]

/********** RDS Module ***************/

db_engine               = "postgres"
db_engine_version       = "14.1"
db_major_engine_version = "14"
db_instance_class       = "db.t4g.small"
db_engine_family        = "postgres14"
db_allocated_storage    = 40
db_maximum_storage      = 100
db_name                 = "gitops"
db_user_name            = "gitops"

/********** EKS Module ***************/

eks_version    = "1.20"
instance_types = ["t3.medium","t3.small"]

/********** Global Variables ***************/
org_name = "gitops"
domain   = "gitops.somedomain.com"