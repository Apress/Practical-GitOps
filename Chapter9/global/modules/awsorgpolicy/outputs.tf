# Output the Policy ID
output "id" {
  value = aws_organizations_policy.default.id
}

# Output the Policy ARN
output "arn" {
  value = aws_organizations_policy.default.arn
}