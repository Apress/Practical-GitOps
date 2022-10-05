// Add only Variables that'll be used Globally across all modules
// Keeping region as default to us-east-2 since its IAM

variable "accounts" {
  description = "Account Names that need to be created."
  type        = map(map(string))
}

variable "users" {
  description = "List of Users, usernames , isAdmin PGP Keys"
  type        = map(map(string))
}

variable "region" {
  description = "Region of Deployment"
  default     = "us-east-2"
}

variable "domain" {
  description = "Primary Domain name"
}

variable "org_name" {
  description = "Name of Organisation"
  type        = string
}