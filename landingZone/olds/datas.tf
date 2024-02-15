data "azurerm_management_group" "management_group" {
  name = var.management_group_name
}

data "azurerm_subscription" "subscription" {
  subscription_id = var.subscription_id
}

//data "azuread_user" "owner_user" {
//  user_principal_name = var.owner
//}