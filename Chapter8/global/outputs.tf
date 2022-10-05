# Spool out Account IDs for using in the Infrastructure Module
output "account_ids" {
  value = {
    identity = module.identity_account.id
    prod     = module.prod_account.id
    staging  = module.staging_account.id
    dev      = module.dev_account.id
  }
}

# Name Servers to update in Parent DNS Zone
output "name_servers" {
  value = {
    prod = {
      domain       = var.domain
      name_servers = join("\n", formatlist("%s.", module.prod.name_servers))
    }
    staging = {
      domain       = "staging.${var.domain}"
      name_servers = join("\n", formatlist("%s.", module.staging.name_servers))
    }
    dev = {
      domain       = "dev.${var.domain}"
      name_servers = join("\n", formatlist("%s.", module.dev.name_servers))
    }
  }
}

# Quick Links for accessing the various AWS Organization accounts
output "links" {
  value = {
    aws_console_sign_identity_account = "https://${module.identity_account.id}.signin.aws.amazon.com/console/"
    aws_console_sign_staging_account  = "https://${module.staging_account.id}.signin.aws.amazon.com/console/"
    aws_console_sign_prod_account     = "https://${module.prod_account.id}.signin.aws.amazon.com/console/"
    switch_role_dev_admin             = "https://signin.aws.amazon.com/switchrole?account=${module.dev_account.id}&roleName=${urlencode(module.dev.assume_admin_role_name)}&displayName=${urlencode("Admin@Dev")}"
    switch_role_staging_admin         = "https://signin.aws.amazon.com/switchrole?account=${module.staging_account.id}&roleName=${urlencode(module.staging.assume_admin_role_name)}&displayName=${urlencode("Admin@staging")}"
    switch_role_prod_admin            = "https://signin.aws.amazon.com/switchrole?account=${module.prod_account.id}&roleName=${urlencode(module.prod.assume_admin_role_name)}&displayName=${urlencode("Admin@prod")}"
  }
}

# Spool out temporary passwords of users created.
output "users" {
  value = {
    for user in var.users :
    user.username => {
      temp_password      = module.users[user.username].temp_password
      role_arns_assigned = local.user_role_mapping[user.role]
    }


  }
}