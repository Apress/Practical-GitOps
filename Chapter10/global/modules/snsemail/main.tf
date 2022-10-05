resource "aws_sns_topic" "default" {
  name = var.name
  tags = {
    terraform-managed = "true"
  }
}

resource "aws_sns_topic_subscription" "default" {
  topic_arn = aws_sns_topic.default.arn
  protocol  = "email"
  endpoint  = var.alert_email
}