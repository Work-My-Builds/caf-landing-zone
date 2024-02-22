output "policy_definition_id" {
  value = [for key, data in azurerm_policy_definition.policy_definition : data.id]
}

output "policy_set_definition_id" {
  value = [for key, data in azurerm_policy_set_definition.policy_set_definition : data.id]
}