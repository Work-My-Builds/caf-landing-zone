resource "azurerm_management_group_subscription_association" "mg_subscription_association" {
  management_group_id = data.azurerm_management_group.management_group.id
  subscription_id     = data.azurerm_subscription.subscription.id
}

resource "azurerm_resource_group" "mon_rg" {
  name     = local.mon_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "data_rg" {
  name     = local.data_resource_group_name
  location = var.location
}