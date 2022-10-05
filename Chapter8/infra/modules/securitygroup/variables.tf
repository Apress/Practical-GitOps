variable "sg_name" {
  description = "Name of the Security group"
  type        = string
}

variable "sg_description" {
  description = "Description of the Security Group"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment to be installed"
  type        = string
}

variable "type" {
  description = "Type INGRESS or EGRESS"
  type        = string
  default     = "INGRESS"
}

variable "from_port" {
  description = "Allowing Traffic From Port"
  type        = number
}

variable "to_port" {
  description = "Allowing Traffic To Port"
  type        = number
}

variable "protocol" {
  description = "Protocol TCP/ICMP/UDP"
  type        = string
  default     = "tcp"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "cidr_blocks" {
  description = "CIDR Blocks to allow traffic to in case of egress/from in case of ingress"
  type        = list(string)
}









