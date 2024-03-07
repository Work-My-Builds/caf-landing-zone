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

variable "exclude_policy_assignments" {
  type    = list(string)
  default = []
}

variable "enable_monitoring_policy_assignments" {
  type    = bool
  default = false
}

variable "enable_backup_policy_assignments" {
  type    = bool
  default = false
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

variable "emailSecurityContact" {
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
    subnets               = optional(list(string), [])
    peered_vnet_id        = optional(list(string), [])
    network_address_space = optional(list(string), [])
    network_dns_address   = optional(list(string), [])
    vpn_client_configuration = object({
      address_space        = list(string)
      vpn_client_protocols = optional(list(string), ["SSTP"])
      vpn_auth_types       = optional(list(string), ["Certificate"])
      root_certificate     = optional(any, {})
    })
    ddos_protection_plan_id        = optional(string, null)
    onpremise_gateway_ip           = optional(string, null)
    onpremise_address_space        = optional(list(string), [])
    onpremise_bgp_peering_settings = optional(any, [])
  })

  default = {
    subnets               = []
    peered_vnet_id        = []
    network_address_space = []
    network_dns_address   = []
    vpn_client_configuration = {
      address_space        = []
      vpn_client_protocols = []
      vpn_auth_types       = []
      root_certificate     = {}
    }
    ddos_protection_plan_id        = null
    onpremise_gateway_ip           = null
    onpremise_address_space        = []
    onpremise_bgp_peering_settings = []
  }
}

variable "mon_resource_group_name" {
  type    = string
  default = ""
}

variable "mon_identity_id" {
  type    = string
  default = ""
}

variable "mon_identity_principal_id" {
  type    = string
  default = ""
}

variable "mon_log_analytics_workspace_id" {
  type    = string
  default = ""
}

variable "mon_storage_account_id" {
  type    = string
  default = ""
}

variable "backup_identity_id" {
  type    = string
  default = ""
}

variable "backup_policy_id" {
  type    = string
  default = ""
}

variable "backup_storage_account_id" {
  type    = string
  default = ""
}
