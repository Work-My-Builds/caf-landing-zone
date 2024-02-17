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

variable "vulnerabilityAssessmentsEmail" {
  type    = string
  default = ""
}

variable "emailSecurityContact" {
  type    = string
  default = ""
}
