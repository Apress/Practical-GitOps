# Create an IAM Policy that allows Assuming the IAM roles for cross-account authentication
resource "aws_iam_policy" "default" {
  name        = "AssumeRoles${var.user_name}"
  description = "Allow IAM User to Assume the IAM Roles"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "${var.roles}"
    }]
  })
  tags = {
    terraform-managed = "true"
  }
}

# Attach the Policy to a particular User
resource "aws_iam_user_policy_attachment" "default" {
  user       = var.user_name
  policy_arn = aws_iam_policy.default.arn
}
