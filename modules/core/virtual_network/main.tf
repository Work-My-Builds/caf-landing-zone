resource "azurerm_resource_group" "network_rg" {
  name     = local.vnet_resource_group_name
  location = var.location
}

resource "azurerm_management_lock" "rg_lock" {
  name       = "CanNotDelete-RG-Level"
  scope      = azurerm_resource_group.network_rg.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group and it's resources can not be deleted"
}

resource "azurerm_network_ddos_protection_plan" "ddos" {
  count = var.enable_hub_network == true ? 1 : 0

  name                = local.ddos_name
  location            = azurerm_resource_group.network_rg.location
  resource_group_name = azurerm_resource_group.network_rg.name

  depends_on = [
    azurerm_management_lock.rg_lock
  ]
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

# Create Azure Policy Assignment
resource "azurerm_subscription_policy_assignment" "policy_assignment" {
  for_each = {
    for assign in local.subscription_policy_assignments : assign.name => assign
  }

  name                 = each.value.name
  location             = var.location
  policy_definition_id = each.value.policy_definition_id
  subscription_id      = each.value.scope
  display_name         = each.value.display_name
  description          = each.value.description
  parameters           = each.value.parameters

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message
    iterator = ncm

    content {
      content = ncm.value
    }
  }

  dynamic "identity" {
    for_each = each.value.identity

    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.uai.id]
    }
  }
}