data "azurerm_management_group" "management_group" {
  name = split("/", local.management_group_id)[4]
}

data "azurerm_subscription" "subscription" {
  subscription_id = split("/", local.subscription_id)[2]
}

data "azuread_group" "group" {
  for_each = {
    for obj in local.groups : "${obj.group}|${obj.role_identifier}" => obj
  }

  display_name = each.value.group
}

data "azuread_user" "user" {
  for_each = {
    for obj in local.users : "${obj.user}|${obj.role_identifier}" => obj
  }

  user_principal_name = each.value.user
}