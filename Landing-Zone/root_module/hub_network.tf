locals {
  virtual_network_gateway = flatten([
    for key, value in module.connectivity.azurerm_vpn_gateway_output.connectivity : {
      resource_group_name          = value.resource_group_name
      virtual_network_gateway_id   = value.id
      virtual_network_gateway_name = value.name
    }
  ])
}

resource "random_string" "random" {
  length           = 24
  special          = true
  override_special = "-_"
}

module "connectivity" {
  source = "./modules/connectivity"

  connectivity_resources_tags  = var.connectivity_resources_tags
  enable_ddos_protection       = var.enable_ddos_protection
  primary_location             = var.primary_location
  root_id                      = var.root_id
  secondary_location           = var.secondary_location
  subscription_id_connectivity = local.subscription_id_connectivity
}

resource "azurerm_local_network_gateway" "on-premise" {
  name                = "Onpremise-Network"
  resource_group_name = local.virtual_network_gateway[0].resource_group_name
  location            = var.primary_location
  gateway_address     = var.onpremise_gateway_ip
  bgp_settings {
    asn                 = var.onpremise_bgp_peering_settings.asn
    bgp_peering_address = var.onpremise_bgp_peering_settings.bgp_peering_address
  }
}

resource "azurerm_virtual_network_gateway_connection" "cloud-to-onpremise" {
  name                = "${local.virtual_network_gateway[0].resource_group_name}-To-${azurerm_local_network_gateway.on-premise.name}"
  location            = var.primary_location
  resource_group_name = local.virtual_network_gateway[0].resource_group_name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = local.virtual_network_gateway[0].virtual_network_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.on-premise.id

  shared_key = random_string.random.result
}