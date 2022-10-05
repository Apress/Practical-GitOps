# Create an IAM Role and attach the EKSRead Only Policy for Developers Group
module "assume_dev_role" {
  source = "./modules/assumerolepolicytrust"

  role_name      = "AssumeRoleDeveloper${var.account}"
  trusted_entity = "arn:aws:iam::${var.identity_account_id}:root"
  policy_arn     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  account        = var.account

}

# Create an AWS ReadOnly Role with a Managed ReadOnlyAccess Policy
module "assume_readonly_role" {
  source = "./modules/assumerolepolicytrust"

  role_name      = "AssumeRoleReadOnly${var.account}"
  trusted_entity = "arn:aws:iam::${var.identity_account_id}:root"
  policy_arn     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  account        = var.account

}

# Create an Admin Role with Administrator Access Policy
module "assume_admin_role" {
  source = "./modules/assumerolepolicytrust"

  role_name      = "AssumeRoleAdmin${var.account}"
  trusted_entity = "arn:aws:iam::${var.identity_account_id}:root"
  policy_arn     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  account        = var.account

}

# Create a Hosted Zone with provided domain name
# Export the Nameservers to update the DNS Records.
resource "aws_route53_zone" "default" {
  name = var.domain

  tags = {
    Account           = var.account
    terraform-managed = "true"
  }
}