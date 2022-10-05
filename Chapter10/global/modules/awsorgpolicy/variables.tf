variable "policy_name" {
  description = "Name of the Policy"
  type        = string
}

variable "description" {
  description = "Description of the Policy"
  type        = string
}

variable "policy_type" {
  description = "AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY, SERVICE_CONTROL_POLICY (SCP), and TAG_POLICY"
  type        = string
  default     = "SERVICE_CONTROL_POLICY"
}

variable "policy_file" {
  description = "Location of the JSON Policy File"
  type        = string

}

variable "account_ids" {
  description = "List of Account IDs to which this Policy needs to be applied to"
  type        = list(string)
}
