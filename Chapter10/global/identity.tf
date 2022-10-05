# Create a Password Policy in the Identity Account as users will be created in this account only
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 10
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true

  provider = aws.identity

}

######################################## USER CREATION ###############################################
# Create an IAM Policy for users to be able to self-manage their accounts
resource "aws_iam_policy" "self_manage" {
  name   = "SelfManaged"
  policy = file("data/self_manage.json")

  provider = aws.identity
}

# Create a SelfManage Group
resource "aws_iam_group" "self_manage" {
  name = "SelfManaged"

  provider = aws.identity
}

# Attach the SelfManage Policy with Group
resource "aws_iam_group_policy_attachment" "self_manage" {
  group      = aws_iam_group.self_manage.name
  policy_arn = aws_iam_policy.self_manage.arn

  provider = aws.identity
}

resource "aws_iam_policy" "iam_admin" {
  name   = "IAMAdministrator"
  policy = file("data/iamadmin.json")

  provider = aws.identity
}

# Create an IAM Administrator Group
resource "aws_iam_group" "iam_admin" {
  name = "IAMAdministrator"

  provider = aws.identity
}

# Attach the IAM Administrator Policy with Group
resource "aws_iam_group_policy_attachment" "iam_admin" {
  group      = aws_iam_group.iam_admin.name
  policy_arn = aws_iam_policy.iam_admin.arn

  provider = aws.identity
}

# Iterate through the users and assign the Group memberships
# For non-admins selfmanage group is assigned by default
module "users" {
  for_each = var.users

  source = "./modules/awsusers"

  user_name = var.users[each.key].username
  pgp_key   = file("data/${var.users[each.key].pgp_key}")

  groups = var.users[each.key].role == "admin" ? [aws_iam_group.iam_admin.name] : [aws_iam_group.self_manage.name]

  providers = {
    aws = aws.identity
  }
}

######################################## USER ROLE MAPPINGS ##############################################

# User to IAMRole Mapping
locals {
  user_role_mapping = {
    developer = [
      module.staging.assume_dev_role_arn,
      module.prod.assume_dev_role_arn,
      module.dev.assume_admin_role_arn
    ],
    admin = [
      module.staging.assume_admin_role_arn,
      module.prod.assume_admin_role_arn,
      module.dev.assume_admin_role_arn,
      module.logging.assume_admin_role_arn
    ],
    readonly = [
      module.staging.assume_readonly_role_arn,
      module.prod.assume_readonly_role_arn,
      module.dev.assume_readonly_role_arn
    ]
  }
}

######################################## Administrator MAPPINGS ##############################################

# Iterate over the User Role Mapping object and assign the specified roles to each user
module "user_role_mapping" {
  source = "./modules/useriamrolepolicyattachment"

  for_each = var.users

  roles     = local.user_role_mapping[each.value["role"]]
  user_name = each.key

  providers = {
    aws = aws.identity
  }

  depends_on = [module.users]
}

