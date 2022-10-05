variable "clustername" {
  description = "Cluster Name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "parameter_name" {
  description = "Name of Parameter to Read"
  type        = string
}

variable "parameter_path" {
  description = "Path of Parameter to Read"
  type        = string
}

variable "parameter_value" {
  description = "Value of the SSM parameter"
  type        = string
}

variable "parameter_type" {
  description = "Type of SSM Parameter to be created"
  type        = string
  default     = "String"
}

variable "parameter_description" {
  description = "Description of the SSM Parameter"
  type        = string
}
