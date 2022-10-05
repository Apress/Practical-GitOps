variable "role_name" {
  description = "The Name of the Role"
  type        = string
}

variable "trusted_entity" {
  description = "The trusted entity who can assume this role."
  type        = string
}

variable "account" {
  description = "Name of the Account"
  type        = string
}

variable "policy_arn" {
  description = "The Policy ARN(s) that needs to be attached to this role"
  type        = list(string)
}



