# Register subscription resource providers
resource "azurerm_resource_provider_registration" "resource_provider_registration" {
  for_each = {
    for prov in local.resource_providers : prov.identifier => prov
  }

  name = each.value.resource_provider_name
}

# Add subscription to management group
resource "azurerm_management_group_subscription_association" "mg_subscription_association" {
  management_group_id = data.azurerm_management_group.management_group.id
  subscription_id     = data.azurerm_subscription.subscription.id

  depends_on = [azurerm_resource_provider_registration.resource_provider_registration]
}

# Create Azure Policy Assignment
resource "azurerm_subscription_policy_assignment" "core_policy_assignment" {
  for_each = {
    for assign in local.core_subscription_policy_assignments : assign.name => assign
  }

  name                 = each.value.name
  location             = var.location
  policy_definition_id = each.value.policy_definition_id
  subscription_id      = each.value.scope
  display_name         = each.value.display_name
  description          = each.value.description
  parameters           = each.value.parameters

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message
    iterator = ncm

    content {
      content = ncm.value
    }
  }
}

# Create Azure Policy Assignment
resource "azurerm_subscription_policy_assignment" "monitoring_policy_assignment" {
  for_each = {
    for assign in local.monitoring_subscription_policy_assignments : assign.name => assign
  }

  name                 = each.value.name
  location             = var.location
  policy_definition_id = each.value.policy_definition_id
  subscription_id      = each.value.scope
  display_name         = each.value.display_name
  description          = each.value.description
  parameters           = each.value.parameters

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message
    iterator = ncm

    content {
      content = ncm.value
    }
  }

  dynamic "identity" {
    for_each = each.value.identity

    content {
      type         = "UserAssigned"
      identity_ids = [var.enable_monitoring == true ? module.monitoring[0].identity_id : var.mon_identity_id]
    }
  }

  depends_on = [
    module.monitoring
  ]
}

resource "azurerm_subscription_policy_assignment" "backup_policy_assignment" {
  count                = var.enable_backup_policy_assignments == true ? 1 : 0
  name                 = "Deploy-VM-Backup"
  location             = var.location
  policy_definition_id = local.backup_policy_definition_id
  subscription_id      = data.azurerm_subscription.subscription.id
  display_name         = local.backup_display_name
  description          = local.backup_description

  non_compliance_message {
    content = local.backup_non_compliance_message
  }

  parameters = <<PARAMETERS
    {
      "exclusionTagName": {
        "value": "NoBackup"
      },
      "exclusionTagValue": {
        "value": [
          "No Backup"
        ]
      },
      "vaultLocation": {
        "value": "${var.location}"
      },
      "backupPolicyId": {
        "value": "${var.enable_backup == true ? module.backup[0].backup_policy_id : var.backup_policy_id}"
      }
    }
  PARAMETERS

  identity {
    type         = "UserAssigned"
    identity_ids = [var.enable_backup == true ? module.backup[0].identity_id : var.backup_identity_id]
  }
}