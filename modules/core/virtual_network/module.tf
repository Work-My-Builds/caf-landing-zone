module "virtual_network_gateway" {
  source = "../virtual_network_gateway"

  count = var.enable_hub_network == true ? 1 : 0

  prefix                         = var.prefix
  business_code                  = var.business_code
  environment                    = var.environment
  location                       = var.location
  vnet_id                        = azurerm_virtual_network.vnet.id
  subnet_ids                     = [ for sub in azurerm_subnet.subnet: sub.id ]
  onpremise_gateway_ip           = var.onpremise_gateway_ip
  onpremise_address_space        = var.onpremise_address_space
  onpremise_bgp_peering_settings = var.onpremise_bgp_peering_settings
}