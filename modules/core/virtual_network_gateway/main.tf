resource "random_string" "random" {
  length           = 24
  special          = true
  override_special = "-_"
}

resource "azurerm_public_ip" "vpn_pip" {
  name                = local.vpn_public_ip_address_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.name
  allocation_method   = "Dynamic"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "afw_pip" {
  name                = local.firewall_public_ip_address_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "afw_management_pip" {
  name                = local.firewall_public_ip_address_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = local.virtual_network_gateway_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.name
  type                = "Vpn"
  vpn_type            = "RouteBased"

  enable_bgp    = true
  active_active = false
  sku           = "VpnGw2AZ"
  generation    = "Generation2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    subnet_id                     = "${data.azurerm_virtual_network.vnet.id}/subnets/GatewaySubnet"
    public_ip_address_id          = azurerm_public_ip.vpn_pip.id
    private_ip_address_allocation = "Dynamic"
  }

  bgp_settings {
    asn = 65515
  }
}

resource "azurerm_firewall_policy" "afwp" {
  name                = local.firewall_policy_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.name
  sku                 = "Premium"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_firewall" "afw" {
  name                = local.firewall_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.name

  sku_name           = "AZFW_VNet"
  sku_tier           = "Premium"
  firewall_policy_id = azurerm_firewall_policy.afwp.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${data.azurerm_virtual_network.vnet.id}/subnets/AzureFirewallSubnet"
    public_ip_address_id = azurerm_public_ip.afw_pip.id
  }

  management_ip_configuration {
    name                 = "managementConfiguration"
    subnet_id            = "${data.azurerm_virtual_network.vnet.id}/subnets/AzureFirewallManagementSubnet"
    public_ip_address_id = azurerm_public_ip.afw_management_pip.id
  }
}

resource "azurerm_local_network_gateway" "on_premise_gateway" {
  name                = local.local_network_gateway_name
  resource_group_name = data.azurerm_virtual_network.vnet.name
  location            = var.location
  gateway_address     = var.onpremise_gateway_ip
  address_space       = var.onpremise_address_space
  dynamic "bgp_settings" {
    for_each = var.onpremise_address_space != null ? var.onpremise_bgp_peering_settings : []
    iterator = bgp

    content {
      asn                 = bgp.value.asn
      bgp_peering_address = bgp.value.bgp_peering_address
    }
  }

  depends_on = [
    azurerm_virtual_network_gateway.vpn
  ]
}

resource "azurerm_virtual_network_gateway_connection" "cloud-to-onpremise" {
  name                = "${azurerm_virtual_network_gateway.vpn.name}-to-${azurerm_local_network_gateway.on_premise_gateway.name}"
  location            = var.location
  resource_group_name = data.azurerm_virtual_network.vnet.name

  type                       = "IPsec"
  enable_bgp                 = var.onpremise_address_space != null ? false : true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.on_premise_gateway.id

  shared_key = random_string.random.result
}