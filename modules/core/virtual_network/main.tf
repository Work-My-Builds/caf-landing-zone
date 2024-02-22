resource "azurerm_resource_group" "network_rg" {
  name     = local.vnet_resource_group_name
  location = var.location
}

resource "azurerm_management_lock" "rg_lock" {
  name       = "CanNotDelete-RG-Level"
  scope      = azurerm_resource_group.network_rg.id
  lock_level = "CanNotDelete"
  notes      = "CanNotDelete lock on this Resource Group and it's resources"

  depends_on = [
    azurerm_network_ddos_protection_plan.ddos,
    azurerm_subnet.subnet,
    azurerm_virtual_network.vnet,
    azurerm_virtual_network_peering.peering
  ]
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

  dynamic "ddos_protection_plan" {
    for_each = (var.enable_hub_network == true && var.ddos_protection_plan_id == null) || var.ddos_protection_plan_id != null ? [var.ddos_protection_plan_id] : []
    #var.enable_hub_network == true || var.ddos_protection_plan_id != null ? [var.ddos_protection_plan_id] : []
    iterator = ddos

    content {
      id     = var.enable_hub_network == true ? azurerm_network_ddos_protection_plan.ddos[0].id : var.ddos_protection_plan_id
      enable = true
    }
  }
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    for subnet in local.subnets : subnet.name => subnet
  }

  name                 = each.value.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefixes]

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

resource "azurerm_network_security_group" "nsg" {
  name                = local.network_security_group_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name
}

resource "azurerm_route_table" "rt" {
  name                          = local.route_table_name
  location                      = azurerm_resource_group.network_rg.location
  resource_group_name           = azurerm_resource_group.network_rg.name
  disable_bgp_route_propagation = false
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = {
    for subnet in local.subnets : subnet.name => subnet
    if var.enable_hub_network != true
  }

  subnet_id                 = azurerm_subnet.subnet[each.value.name].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "rt_association" {
  for_each = {
    for subnet in local.subnets : subnet.name => subnet
    if var.enable_hub_network != true
  }

  subnet_id      = azurerm_subnet.subnet[each.value.name].id
  route_table_id = azurerm_route_table.rt.id
}

resource "azurerm_virtual_network_peering" "peering" {
  for_each = {
    for peer in local.peering : peer.peering_name => peer
  }

  name                         = "${azurerm_virtual_network.vnet.name}-to-${each.value.peering_name}"
  resource_group_name          = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = each.value.peering_id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}