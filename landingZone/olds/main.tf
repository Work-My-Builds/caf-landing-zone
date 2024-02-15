resource "azurerm_management_group_subscription_association" "mg_subscription_association" {
  management_group_id = data.azurerm_management_group.management_group.id
  subscription_id     = data.azurerm_subscription.subscription.id
}

/*data "azurerm_management_group" "management_group" {
  for_each = {
    for mg in var.subscription_landing: mg.key => mg
  }

  name = each.value.management_group_name
}

data "azurerm_subscription" "subscription" {
  for_each = {
    for sub in var.subscription_landing: sub.key => sub
  }

  subscription_id = each.value.subscription_id
}

resource "azurerm_management_group_subscription_association" "mg_subscription_association" {
  for_each = {
    for sub in var.subscription_landing: sub.key => sub
  }

  management_group_id = data.azurerm_management_group.management_group[each.key].id
  subscription_id     = data.azurerm_subscription.subscription[each.key].id
}*/