variable "user_name" {
  description = "Username of the AWS User"
  type        = string
}

variable "pgp_key" {
  description = "PGP Key used for encrypting the secrets"
  type        = string
}

variable "groups" {
  description = "List of Groups that need to be attached"
  type        = list(string)
}