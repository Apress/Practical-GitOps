# AWS Security Group definition
resource "aws_security_group" "security_group" {
  name_prefix = "${var.sg_name}-"
  vpc_id      = var.vpc_id
  description = var.sg_description
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Environment"     = var.environment
    terraform-managed = "true"
  }
}

# AWS Security Group Rules definition
resource "aws_security_group_rule" "security_group_rule" {
  type              = var.type
  from_port         = var.from_port
  to_port           = var.to_port
  protocol          = var.protocol
  cidr_blocks       = var.cidr_blocks
  security_group_id = aws_security_group.security_group.id

}