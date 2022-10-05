module "deny_user_creation_scp" {
  source = "./modules/awsorgpolicy"

  policy_name = "DenyUserCreationSCP"
  description = "Deny Creation of Users in all accounts except Identity"
  policy_file = "data/deny_creating_users.json"
  account_ids = [aws_organizations_organizational_unit.deployment.id, aws_organizations_organizational_unit.development.id]

  depends_on = [resource.aws_organizations_organization.root]
}

module "instance_type_limit_scp" {
  source = "./modules/awsorgpolicy"

  policy_name = "InstanceTypeLimitSCP"
  description = "Restrict EC2 and DB instance types for dev/staging environments"
  policy_file = "data/instance_type_limit.json"

  account_ids = [module.staging_account.id, aws_organizations_organizational_unit.development.id]

  depends_on = [resource.aws_organizations_organization.root]

}

module "region_lock_scp" {
  source = "./modules/awsorgpolicy"

  policy_name = "RegionLockSCP"
  description = "Restrict AWS Services and Regions to particular values"
  policy_file = "data/region_lock.json"

  account_ids = [aws_organizations_organization.root.roots[0].id]

  depends_on = [resource.aws_organizations_organization.root]
}

module "ebs_rds_encryption_scp" {
  source = "./modules/awsorgpolicy"

  policy_name = "EBSRDSEncryptionSCP"
  description = "EBS Blocks and RDS Storage must be encrypted"
  policy_file = "data/ebs_rds_encryption_check.json"

  account_ids = [module.prod_account.id]

  depends_on = [resource.aws_organizations_organization.root]
} 