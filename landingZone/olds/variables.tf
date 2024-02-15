#variable "subscription_landing" {
#  type = list(object({
#    management_group_name = string
#    subscription_id = string
#    policy_assignment_identity = string
#    location = optional(string, "eastus")
#  }))
#}



variable "management_group_name" {
  type = string
}

variable "subscription_name" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "users" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "rg_substring" {
  type = string
}

variable "prefix" {
  type        = string
  description = "Prefix of the name of the all resources"
}
