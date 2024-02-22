output "resource_group_name" {
  value = azurerm_resource_group.mon_rg.name
}

output "identity_id" {
  value = azurerm_user_assigned_identity.uai.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.oms.id
}

output "storage_account_id" {
  value = azurerm_storage_account.sa.id
}