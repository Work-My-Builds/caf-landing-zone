variable "prefix" {
  type = string
}

variable "business_code" {
  type = string
}

variable "environment" {
  type    = string
  default = ""
}

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

variable "location" {
  type = string
}

variable "role_assignments" {
  type = object({
    group_data = optional(map(string), {})
    user_data  = optional(map(string), {})
  })

  default = {}
}

variable "enable_policy_assignments" {
  type    = bool
  default = false
}

variable "exclude_policy_assignments" {
  type    = list(string)
  default = []
}

variable "enable_monitoring" {
  type    = bool
  default = false
}

variable "enable_backup" {
  type    = bool
  default = false
}

variable "vulnerabilityAssessmentsEmail" {
  type    = string
  default = ""
}

variable "logAnalyticWorkspaceID" {
  type    = string
  default = ""
}

variable "emailSecurityContact" {
  type    = string
  default = ""
}

variable "ascExportResourceGroupName" {
  type    = string
  default = ""
}

variable "vulnerabilityAssessmentsStorageID" {
  type    = string
  default = ""
}

variable "enable_network" {
  type    = bool
  default = false
}

variable "enable_hub_network" {
  type    = bool
  default = false
}

variable "virtual_network" {
  type = object({
    subnets                        = optional(list(string), [])
    peered_vnet_id                 = optional(list(string), [])
    network_address_space          = optional(list(string), [])
    network_dns_address            = optional(list(string), [])
    ddos_protection_plan_id        = optional(string, null)
    onpremise_gateway_ip           = optional(string, null)
    onpremise_address_space        = optional(list(string), [])
    onpremise_bgp_peering_settings = optional(any, [])
  })

  default = {
    subnets                        = []
    peered_vnet_id                 = []
    network_address_space          = []
    network_dns_address            = []
    ddos_protection_plan_id        = null
    onpremise_gateway_ip           = null
    onpremise_address_space        = []
    onpremise_bgp_peering_settings = []
  }
}