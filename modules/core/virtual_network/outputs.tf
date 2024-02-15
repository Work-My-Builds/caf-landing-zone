output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "ddos_id" {
  value = var.enable_hub_network == true ? azurerm_network_ddos_protection_plan.ddos[0].id : null
}