variable "account" {
  description = "Name of the Account"
  type        = string
}

variable "domain" {
  description = "Domain Name for Hosted Zone Configuration"
  type        = string
}

variable "identity_account_id" {
  description = "AWS Organisation Account ID of the Identity Account"
  type        = number
}