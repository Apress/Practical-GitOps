# Intialising Root Organisation
resource "aws_organizations_organization" "root" {
}

# Create an OU for Identity management
resource "aws_organizations_organizational_unit" "identity" {
  name      = "Identity Management Account"
  parent_id = aws_organizations_organization.root.roots[0].id
}

# Create an OU for deployment accounts
resource "aws_organizations_organizational_unit" "deployment" {
  name      = "Deployment Accounts"
  parent_id = aws_organizations_organization.root.roots[0].id
}

# Create an OU for development/sandbox accounts
resource "aws_organizations_organizational_unit" "development" {
  name      = "Development Accounts"
  parent_id = aws_organizations_organization.root.roots[0].id
}

# Org for creating users only. This will be a bastion account where users will log in
# and assume role into other accounts.
module "identity_account" {
  source = "./modules/awsaccounts"

  name      = var.accounts["identity"].name
  email     = var.accounts["identity"].email
  parent_id = aws_organizations_organizational_unit.identity.id

}

# Org hosting Production infrastructure
module "prod_account" {
  source = "./modules/awsaccounts"

  name      = var.accounts["prod"].name
  email     = var.accounts["prod"].email
  parent_id = aws_organizations_organizational_unit.deployment.id

}

# Org hosting Staging/pre-prod infrastructure
module "staging_account" {
  source = "./modules/awsaccounts"

  name      = var.accounts["staging"].name
  email     = var.accounts["staging"].email
  parent_id = aws_organizations_organizational_unit.deployment.id

}

# Org hosting Developers infrastructure
module "dev_account" {
  source = "./modules/awsaccounts"

  name      = var.accounts["dev"].name
  email     = var.accounts["dev"].email
  parent_id = aws_organizations_organizational_unit.development.id

}
