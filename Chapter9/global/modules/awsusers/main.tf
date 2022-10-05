# Create an AWS Human user with provided username
resource "aws_iam_user" "default" {
  name = var.user_name
  tags = {
    terraform-managed = "true"
  }
}

# Create a login profile to generate a temporary password encrypted with the provided PGP key
# Mandatory Reset of password
resource "aws_iam_user_login_profile" "default" {
  user                    = aws_iam_user.default.name
  pgp_key                 = var.pgp_key
  password_reset_required = true
  lifecycle {
    ignore_changes = [
      password_reset_required
    ]
  }
}

# Add User to the Groups provided
resource "aws_iam_user_group_membership" "default" {
  user   = aws_iam_user.default.name
  groups = var.groups
}