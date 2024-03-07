# Create App Service Plan
resource "azurerm_service_plan" "app_service_plan_resource" {
  for_each = {
    for plan in local.service_plans : "${plan.plan_key}|${plan.location}" => plan
  }

  name                   = each.value.service_plan_name
  resource_group_name    = each.value.resource_group_name
  location               = each.value.location
  os_type                = each.value.os_type
  sku_name               = each.value.sku_name
  zone_balancing_enabled = each.value.zone_balancing_enabled

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create Application Insights
resource "azurerm_application_insights" "applicationinsights_resource" {
  for_each = {
    for insight in local.app_services : "${insight.plan_key}|${insight.location}|${insight.app_key}" => insight
  }

  name                = "${each.value.appservice_name}-app-insight"
  resource_group_name = each.value.appservice_resource_group_name
  location            = each.value.location
  application_type    = try(each.value.application_type, "web")
  retention_in_days   = try(each.value.retention_in_days, 90)
  sampling_percentage = try(each.value.sampling_percentage, 0)
  disable_ip_masking  = try(each.value.disable_ip_masking, false)
  workspace_id        = each.value.log_analytics_workspace_id

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Create Windows App Service
resource "azurerm_windows_web_app" "appservice_app_resource" {
  for_each = {
    for win in local.app_services : "${win.plan_key}|${win.location}|${win.app_key}" => win if lower(win.os_type) == "windows"
  }

  name                      = each.value.appservice_name
  resource_group_name       = each.value.appservice_resource_group_name
  location                  = each.value.location
  enabled                   = true
  https_only                = true
  client_affinity_enabled   = each.value.client_affinity_enabled
  virtual_network_subnet_id = data.azurerm_subnet.integration_subnet_data_source["${each.value.plan_key}|${each.value.location}"].id

  identity {
    type = "SystemAssigned"
  }

  app_settings = each.value.app_settings != "None" ? merge(each.value.app_settings, local.windows_app_settings,
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].connection_string
    }) : merge(local.windows_app_settings,
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].connection_string
  })



  site_config {
    always_on              = true
    ftps_state             = "FtpsOnly"
    http2_enabled          = false
    websockets_enabled     = false
    vnet_route_all_enabled = true
    #api_management_api_id  = each.value.api_management_api_id

    cors {
      allowed_origins = each.value.allowed_origins
    }
  }

  service_plan_id = azurerm_service_plan.app_service_plan_resource["${each.value.plan_key}|${each.value.location}"].id

  lifecycle {
    ignore_changes = [
      site_config.0.api_management_api_id,
      tags,
    ]
  }
}

# Create Linux App Service
resource "azurerm_linux_web_app" "appservice_app_resource" {
  for_each = {
    for lin in local.app_services : "${lin.plan_key}|${lin.location}|${lin.app_key}" => lin if lower(lin.os_type) == "linux"
  }

  name                      = each.value.appservice_name
  resource_group_name       = each.value.appservice_resource_group_name
  location                  = each.value.location
  enabled                   = true
  https_only                = true
  client_affinity_enabled   = each.value.client_affinity_enabled
  virtual_network_subnet_id = data.azurerm_subnet.integration_subnet_data_source["${each.value.plan_key}|${each.value.location}"].id

  identity {
    type = "SystemAssigned"
  }

  app_settings = each.value.app_settings != "None" ? merge(each.value.app_settings, local.linux_app_settings,
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].connection_string
    }) : merge(local.linux_app_settings,
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].connection_string
  })

  site_config {
    always_on              = true
    ftps_state             = "FtpsOnly"
    http2_enabled          = false
    websockets_enabled     = false
    vnet_route_all_enabled = true
    #api_management_api_id  = each.value.api_management_api_id

    cors {
      allowed_origins = each.value.allowed_origins
    }
  }

  service_plan_id = azurerm_service_plan.app_service_plan_resource["${each.value.plan_key}|${each.value.location}"].id

  lifecycle {
    ignore_changes = [
      site_config.0.api_management_api_id,
      tags,
    ]
  }
}

# Create Windows App Service Slot
resource "azurerm_windows_web_app_slot" "appservice_slot_resource" {
  for_each = {
    for win in local.app_serviceslots : "${win.plan_key}|${win.location}|${win.app_key}|${win.slot_key}" => win if lower(win.os_type) == "windows"
  }

  name                      = each.value.slot_name
  enabled                   = true
  https_only                = true
  client_affinity_enabled   = each.value.client_affinity_enabled
  virtual_network_subnet_id = data.azurerm_subnet.integration_subnet_data_source["${each.value.plan_key}|${each.value.location}"].id

  app_service_id = azurerm_windows_web_app.appservice_app_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].id

  identity {
    type = "SystemAssigned"
  }

  app_settings = each.value.app_settings != "None" ? merge(each.value.app_settings, local.windows_app_settings,
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].connection_string
    }) : merge(local.windows_app_settings,
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].connection_string
  })

  site_config {
    always_on              = true
    ftps_state             = "FtpsOnly"
    http2_enabled          = false
    websockets_enabled     = false
    vnet_route_all_enabled = true
    #api_management_api_id  = each.value.api_management_api_id

    cors {
      allowed_origins = each.value.allowed_origins
    }
  }

  lifecycle {
    ignore_changes = [
      site_config.0.api_management_api_id,
      tags,
    ]
  }
}

# Create Linux App Service Slot
resource "azurerm_linux_web_app_slot" "appservice_slot_resource" {
  for_each = {
    for lin in local.app_serviceslots : "${lin.plan_key}|${lin.location}|${lin.app_key}|${lin.slot_key}" => lin if lower(lin.os_type) == "linux"
  }

  name                      = each.value.slot_name
  enabled                   = true
  https_only                = true
  client_affinity_enabled   = each.value.client_affinity_enabled
  virtual_network_subnet_id = data.azurerm_subnet.integration_subnet_data_source["${each.value.plan_key}|${each.value.location}"].id

  app_service_id = azurerm_linux_web_app.appservice_app_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].id


  identity {
    type = "SystemAssigned"
  }

  app_settings = each.value.app_settings != "None" ? merge(each.value.app_settings, local.linux_app_settings,
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].connection_string
    }) : merge(local.linux_app_settings,
    {
      APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.applicationinsights_resource["${each.value.plan_key}|${each.value.location}|${each.value.app_key}"].connection_string
  })

  site_config {
    always_on              = true
    ftps_state             = "FtpsOnly"
    http2_enabled          = false
    websockets_enabled     = false
    vnet_route_all_enabled = true
    #api_management_api_id  = each.value.api_management_api_id

    cors {
      allowed_origins = each.value.allowed_origins
    }
  }

  lifecycle {
    ignore_changes = [
      site_config.0.api_management_api_id,
      tags,
    ]
  }
}