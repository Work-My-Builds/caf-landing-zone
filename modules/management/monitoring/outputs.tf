output "identity_id" {
  value = azurerm_user_assigned_identity.uai.id
}

output "log_analytics_workspace_rg_name" {
  value = local.mon_resource_group_name
}

output "log_analytics_workspace_name" {
  value = local.log_analytics_workspace_name
}