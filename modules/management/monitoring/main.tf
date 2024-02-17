resource "azurerm_resource_group" "mon_rg" {
  name     = local.mon_resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "uai" {
  name                = local.user_assigned_identity_name
  location            = azurerm_resource_group.mon_rg.location
  resource_group_name = azurerm_resource_group.mon_rg.name
}

module "role_assignment" {
  source = "../../role_assignments"

  for_each = toset(local.role_definitions)

  name                  = each.value
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = azurerm_user_assigned_identity.uai.principal_id
}

resource "azurerm_log_analytics_workspace" "oms" {
  name                = local.log_analytics_workspace_name
  location            = azurerm_resource_group.mon_rg.location
  resource_group_name = azurerm_resource_group.mon_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  location                 = azurerm_resource_group.mon_rg.location
  resource_group_name      = azurerm_resource_group.mon_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_data_collection_rule" "dcr" {

  name                = local.data_collection_rule_name
  location            = azurerm_resource_group.mon_rg.location
  resource_group_name = azurerm_resource_group.mon_rg.name

  destinations {
    azure_monitor_metrics {
      name = "azureMonitorMetrics"
    }
    log_analytics {
      name                  = azurerm_log_analytics_workspace.oms.name
      workspace_resource_id = azurerm_log_analytics_workspace.oms.id
    }
  }

  data_sources {
    extension {
      extension_name = "DependencyAgent"
      name           = "DependencyAgentDataSource"
      streams        = local.data_sources.extension.streams
    }
    performance_counter {
      counter_specifiers            = local.data_sources.performance_counter.counter_specifiers
      name                          = "perfCounterDataSource60"
      sampling_frequency_in_seconds = 60
      streams                       = local.data_sources.performance_counter.streams
    }
    syslog {
      facility_names = local.data_sources.syslog.facility_names
      log_levels     = local.data_sources.syslog.log_levels
      name           = "sysLogsDataSource"
      streams        = local.data_sources.syslog.streams
    }
    windows_event_log {
      name           = "eventLogsDataSource"
      streams        = local.data_sources.windows_event_log.streams
      x_path_queries = local.data_sources.windows_event_log.x_path_queries
    }
  }

  data_flow {
    destinations = [
      "azureMonitorMetrics"
    ]
    streams = [
      "Microsoft-InsightsMetrics"
    ]
  }
  data_flow {
    destinations = [
      azurerm_log_analytics_workspace.oms.name,
    ]
    streams = [
      "Microsoft-Perf",
    ]
  }
  data_flow {
    destinations = [
      azurerm_log_analytics_workspace.oms.name,
    ]
    streams = [
      "Microsoft-Event",
    ]
  }
  data_flow {
    destinations = [
      azurerm_log_analytics_workspace.oms.name,
    ]
    streams = [
      "Microsoft-Syslog",
    ]
  }
}

# Create Azure Policy Assignment
resource "azurerm_subscription_policy_assignment" "policy_assignment" {
  for_each = {
    for assign in local.subscription_policy_assignments : assign.name => assign
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
      identity_ids = [azurerm_user_assigned_identity.uai.id]
    }
  }
}