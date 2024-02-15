resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = local.user_assigned_identity_name
  location            = azurerm_resource_group.mon_rg.location
  resource_group_name = azurerm_resource_group.mon_rg.name
}

resource "azurerm_log_analytics_workspace" "oms" {
  name                = local.log_analytics_workspace_name
  location            = azurerm_resource_group.mon_rg.location
  resource_group_name = azurerm_resource_group.mon_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identity.id]
  }
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