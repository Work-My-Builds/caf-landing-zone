data "azurerm_client_config" "current" {}

data "azurerm_management_group" "management_group" {
  name = var.management_group_name
}

data "azurerm_subscription" "subscription" {
  subscription_id = split("/", var.subscription_id)[2]
}

data "azuread_user" "user" {
  for_each = {
    for obj in local.users : "${obj.role_identifier}|${obj.user}" => obj
  }

  user_principal_name = each.value.user
}