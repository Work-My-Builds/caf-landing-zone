variable "subscription_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "exclude_policy_assignments" {
  type    = list(string)
  default = []
}

variable "enable_hub_network" {
  type    = bool
  default = false
}

variable "subnets" {
  type    = list(string)
  default = null
}

variable "peered_vnet_id" {
  type    = list(string)
  default = []
}

variable "network_address_space" {
  type    = list(string)
  default = null
}

variable "network_dns_address" {
  type    = list(string)
  default = null
}

variable "ddos_protection_plan_id" {
  type    = string
  default = null
}