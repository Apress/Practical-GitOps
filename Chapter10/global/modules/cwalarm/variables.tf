variable "cw_group_name" {
  description = "Name of the CloudWatch Group"
  type        = string
}

variable "name" {
  description = "Generic Name for Filter and Alarm"
  type        = string
}

variable "pattern" {
  description = "Filter Pattern"
  type        = string
}

variable "metric_filter_count" {
  description = "Count of the Metric Filter"
  type        = string
}

variable "metric_filter_namespace" {
  description = "Metric Filter Namespace"
  type        = string
}

variable "description" {
  description = "Metric Alarm Description"
  type        = string
}

variable "metric_alarm_statistic" {
  description = "Metric Alarm Statistic"
  type        = string
}

variable "metric_alarm_period" {
  description = "Metric Alarm Period"
  type        = string
}

variable "metric_alarm_threshold" {
  description = "Metric Alarm Threshold"
  type        = string
}

variable "metric_alarm_evaluation_periods" {
  description = "Metric Alarm Evaluation Periods"
  type        = string
}

variable "metric_alarm_comparison_operator" {
  description = "Metric Alarm Comparison Operator"
  type        = string
}

variable "metric_alarm_treat_missing_data" {
  description = "Metric Alarm Missing Data Treatment"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN To Send Emails"
  type        = string
}



