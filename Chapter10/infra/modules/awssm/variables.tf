variable "description" {
  description = ""
  type        = string
}

variable "deletion_window_in_days" {
  description = "Deletion Window in Days. Resource will not be destroyed uptil the mentioned period"
  type        = number
}

variable "parameter_name" {
  description = "Name of secret to store"
  type        = string
}

variable "secret_value" {
  description = "Secret value to store"
  type        = string
}

variable "environment" {
  description = "The Deployment environment"
  type        = string
}