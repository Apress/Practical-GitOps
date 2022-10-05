# Variable Declaration
variable "environment" {
  description = "The environment e.g uat or prod or dev"
  type        = string
}

variable "region" {
  description = "The region where we wish to deploy to"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH Keyname"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}


