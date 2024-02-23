# Add subscription to management group
resource "azurerm_management_group_subscription_association" "mg_subscription_association" {
  management_group_id = data.azurerm_management_group.management_group.id
  subscription_id     = data.azurerm_subscription.subscription.id
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
      identity_ids = [module.monitoring[0].identity_id]
    }
  }

  depends_on = [
    module.monitoring
  ]
}

resource "azurerm_subscription_policy_assignment" "backup_policy_assignment" {
  count                = var.enable_backup == true ? 1 : 0
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
        "value": "${module.backup[0].backup_policy_id}"
      }
    }
  PARAMETERS

  identity {
    type         = "UserAssigned"
    identity_ids = [module.backup[0].identity_id]
  }
}