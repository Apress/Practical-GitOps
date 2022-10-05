variable "description" {
  description = ""
  type        = string
}

variable "kms_alias" {
  description = "KMS Alias"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Deletion Window in Days. Resource will not be destroyed uptil the mentioned period"
  type        = number
}

variable "key_enabled" {
  description = "Key Enabled"
  type        = bool
  default     = true
}

variable "environment" {
  description = "The Deployment environment"
  type        = string
}