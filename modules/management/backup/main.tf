resource "azurerm_resource_group" "data_rg" {
  name     = local.data_resource_group_name
  location = var.location
}

resource "azurerm_management_lock" "rg_lock" {
  name       = "CanNotDelete-RG-Level"
  scope      = azurerm_resource_group.data_rg.id
  lock_level = "CanNotDelete"
  notes      = "CanNotDelete lock on this Resource Group and it's resources"

  depends_on = [
    azurerm_backup_policy_vm.rsv_vm_policy,
    azurerm_data_protection_backup_vault.bk,
    azurerm_key_vault.kv,
    azurerm_recovery_services_vault.rsv,
    azurerm_storage_account.sa,
    azurerm_user_assigned_identity.uai
  ]
}

resource "azurerm_user_assigned_identity" "uai" {
  name                = local.user_assigned_identity_name
  location            = azurerm_resource_group.data_rg.location
  resource_group_name = azurerm_resource_group.data_rg.name
}

module "role_assignment" {
  source = "../../role_assignments"

  for_each = toset(local.role_definitions)

  name                  = each.value
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = azurerm_user_assigned_identity.uai.principal_id
}

resource "azurerm_key_vault" "kv" {
  name                          = local.key_vault_name
  location                      = azurerm_resource_group.data_rg.location
  resource_group_name           = azurerm_resource_group.data_rg.name
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
  sku_name                      = "standard"
  public_network_access_enabled = false
}

resource "azurerm_storage_account" "sa" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.data_rg.name
  location                        = azurerm_resource_group.data_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  share_properties {
    retention_policy {
      days = 7
    }
    smb {
      versions = ["SMB3.0", "SMB3.1.1"]
    }
  }

  network_rules {
    default_action = "Deny"
  }
}

resource "azurerm_data_protection_backup_vault" "bk" {
  name                = local.backup_vault_name
  resource_group_name = azurerm_resource_group.data_rg.name
  location            = azurerm_resource_group.data_rg.location
  datastore_type      = "VaultStore"
  redundancy          = "GeoRedundant"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_recovery_services_vault" "rsv" {
  name                         = local.recovery_service_vault_name
  location                     = azurerm_resource_group.data_rg.location
  resource_group_name          = azurerm_resource_group.data_rg.name
  sku                          = "Standard"
  cross_region_restore_enabled = true

  soft_delete_enabled = true
}

resource "azurerm_backup_policy_vm" "rsv_vm_policy" {
  name                = "PlatformEnhanceVMPolicy"
  resource_group_name = azurerm_recovery_services_vault.rsv.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  policy_type         = "V2"

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}