variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "subnet_ids" {
  type = map(string)
}

variable "onpremise_gateway_ip" {
  type = string
}
variable "onpremise_address_space" {
  type    = list(string)
  default = null
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "vpn_client_configuration" {
  type = object({
    address_space        = list(string)
    vpn_client_protocols = optional(list(string), ["SSTP"])
    vpn_auth_types       = optional(list(string), ["Certificate"])
    root_certificate     = optional(any, {})
  })
}

variable "onpremise_bgp_peering_settings" {
  type = list(object({
    asn                 = number
    bgp_peering_address = string
  }))
  description = "On premise gateway BGP IP address"
  default     = []
}