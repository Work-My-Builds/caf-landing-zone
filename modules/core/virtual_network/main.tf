resource "azurerm_resource_group" "network_rg" {
  name     = local.vnet_resource_group_name
  location = var.location
}

resource "azurerm_network_ddos_protection_plan" "ddos" {
  count = var.enable_hub_network == true ? 1 : 0

  name                = local.ddos_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.virtual_network_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
  address_space       = var.network_address_space
  dns_servers         = var.network_dns_address

  ddos_protection_plan {
    id     = var.enable_hub_network == true ? azurerm_network_ddos_protection_plan.ddos[0].id : var.ddos_protection_plan_id
    enable = true
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    for subnet in module.subnet_addrs.networks : subnet.name => subnet
  }

  name                 = each.value.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.cidr_block]

  dynamic "delegation" {
    for_each = lower(split("-", each.value.name)[length(split("-", each.value.name)) - 1]) == "web" ? [1] : []

    content {
      name = local.delegation.name

      service_delegation {
        name    = local.delegation.service_delegation.name
        actions = local.delegation.service_delegation.actions
      }
    }
  }
}

#resource "azurerm_virtual_network_peering" "peering" {
#  name                         = "${azurerm_virtual_network.vnet.name}-to-${split("/", var.peered_vnet_id)[8]}"
#  resource_group_name          = azurerm_virtual_network.vnet.resource_group_name
#  virtual_network_name         = azurerm_virtual_network.vnet.name
#  remote_virtual_network_id    = var.peered_vnet_id
#  allow_virtual_network_access = true
#  allow_forwarded_traffic      = true
#  allow_gateway_transit        = var.enable_hub_network == true ? true : false
#  use_remote_gateways          = var.enable_hub_network == true ? false : true
#
#  triggers = {
#    remote_address_space = join(",", data.azurerm_virtual_network.hub_vnet.address_space)
#  }
#}


resource "azurerm_private_dns_zone" "pdz" {
  for_each = {
    for dns in local.private_dns_zones : dns.private_dns_zone_name => dns
  }

  name                = each.value.private_dns_zone_name
  resource_group_name = azurerm_resource_group.network_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pdzl" {
  for_each = {
    for dns in local.private_dns_zones : dns.private_dns_zone_name => dns
  }

  name                  = azurerm_virtual_network.vnet.name
  resource_group_name   = azurerm_virtual_network.vnet.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.pdz[each.value.private_dns_zone_name].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}