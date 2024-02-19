variable "root_scope_resource_id" {
  type    = string
  default = ""
}

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

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "policy_definition_depencies" {
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
