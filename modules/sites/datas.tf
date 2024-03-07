data "azurerm_client_config" "client_config" {
}

data "azurerm_subnet" "int_subnet" {
  for_each = {
    for sub in local.service_plans : sub.key => sub
  }

  name                 = each.value.integration_subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.vnet_resource_group_name
}

data "azurerm_subnet" "pe_subnet" {
  for_each = {
    for sub in local.service_plans : sub.key => sub
  }

  name                 = each.value.private_endpoint_subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.vnet_resource_group_name
}