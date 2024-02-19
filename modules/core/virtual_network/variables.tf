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

variable "vnet_id" {
  type    = string
  default = null
}

variable "onpremise_gateway_ip" {
  type    = string
  default = null
}
variable "onpremise_address_space" {
  type    = list(string)
  default = null
}

variable "onpremise_bgp_peering_settings" {
  type = list(object({
    asn                 = number
    bgp_peering_address = string
  }))
  description = "On premise gateway BGP IP address"
  default = [{
    asn                 = null
    bgp_peering_address = null
  }]
}