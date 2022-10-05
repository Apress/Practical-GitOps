variable "es_instance_type" {
  description = "Elasticsearch Instance Type"
  type        = string
}

variable "es_instance_count" {
  description = "Elasticsearch Instance Count"
  type        = number
}

variable "es_version" {
  description = "Elasticsearch Version"
  type        = string
}

variable "fb_version" {
  description = "AWS FluentBit Daemon Version https://github.com/aws/aws-for-fluent-bit"
  type        = string
}

variable "oidc_url" {
  description = "OIDC URL"
  type        = string
}

variable "oidc_arn" {
  description = "OIDC ARN"
  type        = string
}

variable "acm_arn" {
  description = "ACM ARN"
  type        = string
}

variable "url" {
  description = "Main Domain URL"
  type        = string
}

variable "zone_id" {
  description = "Zone ID"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "fluentbit_count_yaml" {
  description = "Count of Fluentbit YAML Filess"
  type        = number
}