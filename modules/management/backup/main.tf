resource "azurerm_resource_group" "data_rg" {
  name     = local.data_resource_group_name
  location = var.location
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
  name                        = local.key_vault_name
  location                    = azurerm_resource_group.data_rg.location
  resource_group_name         = azurerm_resource_group.data_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  sku_name                    = "standard"
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.data_rg.name
  location                 = azurerm_resource_group.data_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_protection_backup_vault" "bk" {
  name                = local.backup_vault_name
  resource_group_name = azurerm_resource_group.data_rg.name
  location            = azurerm_resource_group.data_rg.location
  datastore_type      = "VaultStore"
  redundancy          = "ZoneRedundant"

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

resource "azurerm_subscription_policy_assignment" "policy_assignment" {
  count                = !contains(var.policy_assignment_to_exclude, "Deploy-VM-Backup") ? 1 : 0
  name                 = "Deploy-VM-Backup"
  location             = var.location
  policy_definition_id = local.policy_definition_id
  subscription_id      = data.azurerm_subscription.subscription.id
  display_name         = var.display_name
  description          = var.description

  non_compliance_message {
    content = var.non_compliance_message
  }

  parameters = <<PARAMETERS
    {
      "exclusionTagName": {
        "value": "Backup"
      },
      "exclusionTagValue": {
        "value": "Enable"
      },
      "recoveryServiceVaultRG": {
        "value": "${azurerm_recovery_services_vault.rsv.resource_group_name}"
      },
      "recoveryServiceVaultName": {
        "value": "${azurerm_recovery_services_vault.rsv.name}"
      }
    }
  PARAMETERS

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }
}