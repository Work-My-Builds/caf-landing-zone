output "mon_resource_group_name" {
  value = var.enable_monitoring == true ? module.monitoring[0].resource_group_name : ""
}

output "mon_identity_id" {
  value = var.enable_monitoring == true ? module.monitoring[0].identity_id : ""
}

output "mon_log_analytics_workspace_id" {
  value = var.enable_monitoring == true ? module.monitoring[0].log_analytics_workspace_id : ""
}

output "mon_storage_account_id" {
  value = var.enable_monitoring == true ? module.monitoring[0].storage_account_id : ""
}

output "backup_dentity_id" {
  value = var.enable_backup == true ? module.backup[0].identity_id : ""
}

output "backup_backup_policy_id" {
  value = var.enable_backup == true ? module.backup[0].backup_policy_id : ""
}

output "backup_storage_account_id" {
  value = var.enable_backup == true ? module.backup[0].storage_account_id : ""
}