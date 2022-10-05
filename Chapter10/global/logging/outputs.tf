output "cw_logs_role_arn" {
  value = aws_iam_role.cloud_trail_assume_role_cw.arn
}

output "cw_logs_arn" {
  value = aws_cloudwatch_log_group.central_logging.arn
}

output "cw_log_group_name" {
  value = aws_cloudwatch_log_group.central_logging.name
}

output "s3_bucket_id" {
  value = aws_s3_bucket.central_logging.id
}

output "assume_admin_role" {
  value = module.assume_admin_role.role_name
}

output "assume_admin_role_arn" {
  value = module.assume_admin_role.role_arn
}