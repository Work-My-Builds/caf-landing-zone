output "role_definition_id" {
  value = [for key, data in azurerm_role_definition.role_definition : data.id]
}