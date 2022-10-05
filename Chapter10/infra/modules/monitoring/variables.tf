variable "prometheus_version" {
  description = "Prometheus Chart Version"
  type        = string
}

variable "grafana_version" {
  description = "Grafana Chart Version"
  type        = string
}

variable "ms_version" {
  description = "Metrics Server Chart Version"
  type        = string
}

variable "url" {
  description = "Primary URL of the Application"
  type        = string
}

variable "acm_arn" {
  description = "ACM ARN for deploy certificate"
  type        = string
}

variable "zone_id" {
  description = "Zone ID"
  type        = string
}