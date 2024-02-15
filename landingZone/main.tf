module "root" {
  source = "../modules/policy"

  location            = var.location
  prefix              = var.prefix
  business_code       = "onl"
  management_group_id = "/providers/Microsoft.Management/managementGroups/livemg"
  subscription_id     = "/subscriptions/b07c6415-3b3e-4968-9c83-5f2218fd57fe"
  #users                             = var.users
  enable_role_definitions   = true
  enable_policy_definitions = true
  #enable_policy_assignments         = true
  #BudgetContactEmails               = var.BudgetContactEmails
  #BudgetAmount                      = var.BudgetAmount
  #vulnerabilityAssessmentsEmail     = var.vulnerabilityAssessmentsEmail
  #logAnalyticWorkspaceID            = var.logAnalyticWorkspaceID
  #emailSecurityContact              = var.emailSecurityContact
  #ascExportResourceGroupName        = var.ascExportResourceGroupName
  #vulnerabilityAssessmentsStorageID = var.vulnerabilityAssessmentsStorageID
  #enable_network                    = var.enable_network
  #enable_monitoring                 = var.enable_monitoring
  #virtual_network                   = var.virtual_network
}

module "online" {
  source = "../modules/policy"

  location            = var.location
  prefix              = var.prefix
  business_code       = "onl"
  management_group_id = "/providers/Microsoft.Management/managementGroups/livemg"
  subscription_id     = "/subscriptions/b07c6415-3b3e-4968-9c83-5f2218fd57fe"
  #users                             = var.users
  #enable_role_definitions           = true
  #enable_policy_definitions         = true
  enable_policy_assignments = true
  #BudgetContactEmails               = var.BudgetContactEmails
  #BudgetAmount                      = var.BudgetAmount
  #vulnerabilityAssessmentsEmail     = var.vulnerabilityAssessmentsEmail
  #logAnalyticWorkspaceID            = var.logAnalyticWorkspaceID
  #emailSecurityContact              = var.emailSecurityContact
  #ascExportResourceGroupName        = var.ascExportResourceGroupName
  #vulnerabilityAssessmentsStorageID = var.vulnerabilityAssessmentsStorageID
  enable_network    = true
  enable_monitoring = true
  virtual_network = {
    enable_hub_network = true
    subnets = [
      "compute:24",
      "pe:28",
      "data:24",
      "web:28"
    ]
    //peered_vnet_id                 = null
    network_address_space   = ["10.0.0.0/16"]
    network_dns_address     = []
    ddos_protection_plan_id = "/subscriptions/b07c6415-3b3e-4968-9c83-5f2218fd57fe/resourceGroups/azuredevops/providers/Microsoft.Network/ddosProtectionPlans/testddos"
    onpremise_gateway_ip    = "100.100.100.100"
    onpremise_address_space = []
    onpremise_bgp_peering_settings = [{
      asn                 = 20120
      bgp_peering_address = "10.0.0.20"
    }]
  }

  providers = {
    azurerm = azurerm.online
  }
}



/*resource "azurerm_management_group_subscription_association" "mg_subscription_association" {
  management_group_id = data.azurerm_management_group.management_group.id
  subscription_id     = data.azurerm_subscription.subscription.id
}

resource "azurerm_resource_group" "mon_rg" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "data_rg" {
  name     = local.data_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "network_rg" {
  count    = var.enable_network == true ? 1 : 0
  name     = local.vnet_resource_group_name
  location = var.location
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

resource "azurerm_log_analytics_workspace" "oms" {
  name                = local.log_analytics_workspace_name
  location            = azurerm_resource_group.mon_rg.location
  resource_group_name = azurerm_resource_group.mon_rg.name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  identity {
    type = var.identity_type
  }
}

resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = local.user_assigned_identity_name
  location            = azurerm_resource_group.mon_rg.location
  resource_group_name = azurerm_resource_group.mon_rg.name
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
  name                = local.recovery_service_vault_name
  location            = azurerm_resource_group.data_rg.location
  resource_group_name = azurerm_resource_group.data_rg.name
  sku                 = "Standard"

  soft_delete_enabled = true
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.enable_network == true ? 1 : 0
  name                = local.virtual_network_name
  location            = azurerm_resource_group.network_rg[0].location
  resource_group_name = azurerm_resource_group.network_rg[0].name
  address_space       = var.network_address_space
  dns_servers         = var.network_dns_address
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.enable_network == true ? toset(local.subnets) : []
  name                 = each.key
  resource_group_name  = azurerm_virtual_network.vnet[0].resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = ["10.0.${index(local.subnets, each.key)}.0/24"]

  dynamic "delegation" {
    for_each = lower(split("-", each.key)[length(split("-", each.key)) - 1]) == "web" ? [1] : []

    content {
      name = local.delegation.name

      service_delegation {
        name    = local.delegation.service_delegation.name
        actions = local.delegation.service_delegation.actions
      }
    }
  }
}*/