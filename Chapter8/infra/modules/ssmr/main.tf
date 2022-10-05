# Read the SSM Parameter from the provided path and parameter name
data "aws_ssm_parameter" "parameter" {
  name = "${var.parameter_path}/${var.parameter_name}"
}