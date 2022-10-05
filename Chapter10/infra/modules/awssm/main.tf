resource "aws_secretsmanager_secret" "secret" {
  name        = var.parameter_name
  description = var.description
  tags = {
    "Environment"     = var.environment
    terraform-managed = "true"
  }
  # https://stackoverflow.com/questions/57431731/terraform-secrets-manager-reuse-of-existing-secrets-without-deleting 
  recovery_window_in_days = var.deletion_window_in_days
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_value
}