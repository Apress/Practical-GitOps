output "ssm-value" {
  value = data.aws_ssm_parameter.parameter.value
}