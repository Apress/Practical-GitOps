# Populate the staging account organization with required IAM Roles and Route53 Hosted Zones
module "staging" {
  source = "./staging"

  account             = "staging"
  identity_account_id = module.identity_account.id
  domain              = "staging.${var.domain}"

  providers = {
    aws = aws.staging
  }

}

# Populate the prod account organization with required IAM Roles and Route53 Hosted Zones
module "prod" {
  source = "./prod"

  account             = "prod"
  identity_account_id = module.identity_account.id
  domain              = var.domain

  providers = {
    aws = aws.prod
  }

}

# Populate the dev account organization with required IAM Roles and Route53 Hosted Zones
module "dev" {
  source = "./dev"

  account             = "dev"
  identity_account_id = module.identity_account.id
  domain              = "dev.${var.domain}"

  providers = {
    aws = aws.dev
  }

}