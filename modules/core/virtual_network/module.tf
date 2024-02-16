#module "subnet_addrs" {
#  source  = "hashicorp/subnets/cidr"
#  version = "1.0.0"
#
#  base_cidr_block = var.network_address_space[0]
#  networks        = local.subnets
#}

module "virtual_network_gateway" {
  source = "../virtual_network_gateway"

  count = var.enable_hub_network == true ? 1 : 0

  prefix                         = var.prefix
  business_code                  = var.business_code
  location                       = var.location
  vnet_id                        = azurerm_virtual_network.vnet.id
  onpremise_gateway_ip           = var.onpremise_gateway_ip
  onpremise_address_space        = var.onpremise_address_space
  onpremise_bgp_peering_settings = var.onpremise_bgp_peering_settings
}