# CReate an IAM Role with an AssumeRole Policy for a trusted entity
resource "aws_iam_role" "default" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          "AWS" : "${var.trusted_entity}"
        }
    }]
  })
  tags = {
    terraform-managed = "true"
    account           = var.account
  }
}

# Attach the Policies provided to the IAM role created above
resource "aws_iam_role_policy_attachment" "default" {
  count      = length(var.policy_arn)
  policy_arn = var.policy_arn[count.index]
  role       = aws_iam_role.default.name
}
