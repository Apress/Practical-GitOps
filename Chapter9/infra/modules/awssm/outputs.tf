output "arn" {
  description = "AWS SecretManager Secret ARN"
  value       = aws_secretsmanager_secret.secret.arn
}

output "id" {
  description = "AWS SecretManager Secret ID"
  value       = aws_secretsmanager_secret.secret.id
}

output "secret" {
  description = "AWS SecretManager Secret resource"
  value       = aws_secretsmanager_secret.secret
}

output "secret_version" {
  description = "AWS SecretManager Secret Version resource"
  value       = aws_secretsmanager_secret_version.secret
}