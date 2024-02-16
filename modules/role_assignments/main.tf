data "azurerm_role_definition" "role_definition" {
  name  = var.name
  scope = var.role_definition_scope
}

resource "azurerm_role_assignment" "role_assignment" {
  scope              = var.scope
  role_definition_id = data.azurerm_role_definition.role_definition.role_definition_id
  principal_id       = var.principal_id
}