output "identity_id" {
  value = azurerm_user_assigned_identity.uai.id
}

output "backup_policy_id" {
  value = azurerm_backup_policy_vm.rsv_vm_policy.id
}

output "storage_account_id" {
  value = azurerm_storage_account.sa.id
}