resource "random_string" "random" {
  length           = 24
  special          = true
  override_special = "-_"
}

resource "azurerm_public_ip" "afw_pip" {
  name                = local.firewall_public_ip_address_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vpn_pip" {
  name                = local.vpn_public_ip_address_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "afwp" {
  name                = local.firewall_policy_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  sku                 = "Premium"

  insights {
    enabled                            = true
    default_log_analytics_workspace_id = var.log_analytics_workspace_id
    retention_in_days                  = 30
  }

  intrusion_detection {
    mode = "Alert"
  }
}

resource "azurerm_firewall" "afw" {
  name                = local.firewall_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  dns_proxy_enabled   = false
  threat_intel_mode   = "Alert"

  sku_name           = "AZFW_VNet"
  sku_tier           = "Premium"
  firewall_policy_id = azurerm_firewall_policy.afwp.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = lookup(var.subnet_ids, "AzureFirewallSubnet", null)
    public_ip_address_id = azurerm_public_ip.afw_pip.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  name                       = "${local.firewall_name}-diag"
  target_resource_id         = azurerm_firewall.afw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = local.virtual_network_gateway_name
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"

  enable_bgp    = false
  active_active = false
  sku           = "VpnGw2"
  generation    = "Generation2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    subnet_id                     = lookup(var.subnet_ids, "GatewaySubnet", null)
    public_ip_address_id          = azurerm_public_ip.vpn_pip.id
    private_ip_address_allocation = "Dynamic"
  }

  vpn_client_configuration {
    address_space        = var.vpn_client_configuration.address_space
    vpn_client_protocols = var.vpn_client_configuration.vpn_client_protocols
    vpn_auth_types       = var.vpn_client_configuration.vpn_auth_types

    dynamic "root_certificate" {
      for_each = var.vpn_client_configuration.root_certificate
      iterator = rc

      content {
        name             = rc.key
        public_cert_data = <<EOF
${rc.value.public_cert_data}
        EOF
      }
    }
  }

  depends_on = [
    azurerm_firewall.afw
  ]
}

resource "azurerm_local_network_gateway" "on_premise_gateway" {
  name                = local.local_network_gateway_name
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
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
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name

  type                       = "IPsec"
  enable_bgp                 = var.onpremise_address_space != null ? false : true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.on_premise_gateway.id

  shared_key = random_string.random.result
}

resource "azurerm_private_dns_zone" "pdz" {
  for_each = {
    for dns in local.private_dns_zones : dns.private_dns_zone_name => dns
  }

  name                = each.value.private_dns_zone_name
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pdzl" {
  for_each = {
    for dns in local.private_dns_zones : dns.private_dns_zone_name => dns
  }

  name                  = data.azurerm_virtual_network.vnet.name
  resource_group_name   = data.azurerm_virtual_network.vnet.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.pdz[each.value.private_dns_zone_name].name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}