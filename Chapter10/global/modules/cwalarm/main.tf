resource "aws_cloudwatch_log_metric_filter" "default" {

  log_group_name = var.cw_group_name
  pattern        = var.pattern
  name           = "${var.name}MetricFilter"
  metric_transformation {
    name      = "${var.name}Count"
    value     = var.metric_filter_count
    namespace = var.metric_filter_namespace
  }

}

resource "aws_cloudwatch_metric_alarm" "default" {

  alarm_name          = "${var.name}MetricAlarm"
  alarm_description   = var.description
  metric_name         = "${var.name}Count"
  namespace           = var.metric_filter_namespace
  statistic           = var.metric_alarm_statistic
  period              = var.metric_alarm_period
  threshold           = var.metric_alarm_threshold
  evaluation_periods  = var.metric_alarm_evaluation_periods
  comparison_operator = var.metric_alarm_comparison_operator
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = var.metric_alarm_treat_missing_data

  tags = {
    terraform-managed = "true"
  }
}
