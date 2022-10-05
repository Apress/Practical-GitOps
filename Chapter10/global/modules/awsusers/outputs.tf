output "user_name" {
  value = aws_iam_user.default.name
}

output "temp_password" {
  value = aws_iam_user_login_profile.default.encrypted_password
}
