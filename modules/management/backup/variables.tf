variable "management_group_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "prefix" {
  type        = string
  description = "Prefix of the name of the all resources"
}

variable "business_code" {
  type = string
}

variable "location" {
  type = string
}

variable "policy_assignment_to_exclude" {
  type    = list(string)
  default = []
}

variable "display_name" {
  type    = string
  default = "Configure backup on virtual machines without a given tag to an existing recovery services vault with a default policy"
}

variable "description" {
  type    = string
  default = "Enforce backup for all virtual machines."
}

variable "non_compliance_message" {
  type    = string
  default = "Backup on virtual machines without a given tag should be configured to an existing recovery services vault with a default policy."
}