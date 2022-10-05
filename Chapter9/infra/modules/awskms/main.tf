resource "aws_kms_key" "default" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.key_enabled
  tags = {
    "Environment"     = var.environment
    terraform-managed = "true"
    Name              = var.kms_alias
  }
}

resource "aws_kms_alias" "default" {
  target_key_id = aws_kms_key.default.key_id
  name          = "alias/${var.kms_alias}"
}