module "virtual_network" {
  source = "../core/virtual_network"

  count = var.enable_network == true ? 1 : 0

  prefix                  = var.prefix
  business_code           = var.business_code
  location                = var.location
  enable_hub_network      = var.virtual_network.enable_hub_network
  subnets                 = var.virtual_network.subnets
  peered_vnet_id          = var.virtual_network.peered_vnet_id
  network_address_space   = var.virtual_network.network_address_space
  network_dns_address     = var.virtual_network.network_dns_address
  ddos_protection_plan_id = var.virtual_network.ddos_protection_plan_id

  onpremise_gateway_ip           = var.virtual_network.onpremise_gateway_ip
  onpremise_address_space        = var.virtual_network.onpremise_address_space
  onpremise_bgp_peering_settings = var.virtual_network.onpremise_bgp_peering_settings
}

module "monitoring" {
  source = "../management"

  count = var.enable_monitoring == true ? 1 : 0

  management_group_name = split("/", var.management_group_id)[4]
  subscription_id       = var.subscription_id
  users                 = var.users
  prefix                = var.prefix
  business_code         = var.business_code
  location              = var.location
}