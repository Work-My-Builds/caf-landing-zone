output "identity_id" {
  value = azurerm_user_assigned_identity.user_assigned_identity.id
}

output "log_analytics_workspace_rg_name" {
  value = local.mon_resource_group_name
}

output "log_analytics_workspace_name" {
  value = local.log_analytics_workspace_name
}

output "storage_account_rg_name" {
  value = local.data_resource_group_name
}

output "storage_account_name" {
  value = local.storage_account_name
}