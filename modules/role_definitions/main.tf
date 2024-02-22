# Create Azure Role Defition
resource "azurerm_role_definition" "role_definition" {
  for_each = {
    for role in local.role_definitions : role.properties.roleName => role
  }

  name        = each.value.properties.roleName
  scope       = local.root_scope_resource_id
  description = each.value.properties.description

  permissions {
    actions          = each.value.properties.permissions[0].actions
    not_actions      = each.value.properties.permissions[0].notActions
    data_actions     = each.value.properties.permissions[0].dataActions
    not_data_actions = each.value.properties.permissions[0].notDataActions
  }
}