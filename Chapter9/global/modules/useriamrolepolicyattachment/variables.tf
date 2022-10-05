variable "user_name" {
  description = "User name of the AWS User"
  type        = string
}

variable "roles" {
  description = "List of Roles that need to be attached to the Users Policy"
  type        = list(string)
}



