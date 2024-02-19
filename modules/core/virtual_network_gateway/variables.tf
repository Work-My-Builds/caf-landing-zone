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

variable "vnet_id" {
  type = string
}

variable "onpremise_gateway_ip" {
  type = string
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