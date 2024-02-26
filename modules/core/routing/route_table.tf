resource "azurerm_route" "routes" {
  for_each = {
    for route in local.routes : "${route.key}|${route.subkey}" => route
  }

  name                   = each.value.route_name
  resource_group_name    = data.azurerm_route_table.rt[each.value.route_table_name].resource_group_name
  route_table_name       = data.azurerm_route_table.rt[each.value.route_table_name].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}