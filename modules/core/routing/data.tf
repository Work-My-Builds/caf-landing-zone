data "azurerm_route_table" "rt" {
  for_each = {
    for rt in local.route_tables : rt.key => rt
  }

  name                = each.value.route_table_name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_firewall_policy" "afwp" {
  for_each = {
    for policy in local.firewall_policy : policy.key => policy
  }

  name                = each.value.firewall_policy_name
  resource_group_name = each.value.resource_group_name
}