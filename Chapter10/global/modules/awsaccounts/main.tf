# Create an AWS Organisations account with provided name,email and parent ID
# By default create an Administrator Role
resource "aws_organizations_account" "default" {
  name      = var.name
  email     = var.email
  parent_id = var.parent_id
  role_name = "Administrator"
  lifecycle {
    ignore_changes = [role_name]
  }
}