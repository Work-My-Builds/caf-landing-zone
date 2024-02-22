resource "azurerm_resource_group" "mon_rg" {
  name     = local.mon_resource_group_name
  location = var.location
}

resource "azurerm_management_lock" "rg_lock" {
  name       = "CanNotDelete-RG-Level"
  scope      = azurerm_resource_group.mon_rg.id
  lock_level = "CanNotDelete"
  notes      = "CanNotDelete lock on this Resource Group and it's resources"

  depends_on = [
    azurerm_log_analytics_workspace.oms,
    azurerm_monitor_data_collection_rule.dcr,
    azurerm_storage_account.sa,
    azurerm_user_assigned_identity.uai
  ]
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
  name                          = local.storage_account_name
  location                      = azurerm_resource_group.mon_rg.location
  resource_group_name           = azurerm_resource_group.mon_rg.name
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false

  #network_rules {
  #  default_action = "Deny"
  #}
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