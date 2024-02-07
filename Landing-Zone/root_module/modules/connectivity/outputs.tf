# Output a copy of configure_connectivity_resources for use
# by the core module instance

output "configuration" {
  description = "Configuration settings for the \"connectivity\" resources."
  value       = local.configure_connectivity_resources
}

output "azurerm_vpn_gateway_output" {
  value = module.alz.azurerm_virtual_network_gateway
}