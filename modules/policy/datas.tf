data "azurerm_management_group" "management_group" {
  name = split("/", var.management_group_id)[4]
}

data "azurerm_subscription" "subscription" {
  subscription_id = split("/", var.subscription_id)[2]
}

data "azuread_user" "user" {
  for_each = {
    for obj in local.users : "${obj.user}|${obj.role_identifier}" => obj
  }

  user_principal_name = each.value.user
}