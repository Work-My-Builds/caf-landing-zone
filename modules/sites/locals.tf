##################################################################################
# Requirements:
##################################################################################

##################################################################################
# Module - Main
##################################################################################

locals {
  geo_codes      = jsondecode(templatefile(".${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile(".${path.root}/assets/resource-codes.json", {}))

  site_resource_group_name = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-net-${var.environment}")
  service_plan_name        = lower("${var.prefix}-${local.resource_codes.resources["Service plan"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-net-${var.environment}")
  app_service_name         = lower("${var.prefix}-${local.resource_codes.resources["Web app"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-net-${var.environment}")
  function_app_name        = lower("${var.prefix}-${local.resource_codes.resources["Function app"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-net-${var.environment}")

  appservice_diag_settings = {
    metrics = "AllMetrics"
    logs    = ["AppServiceAntivirusScanAuditLogs", "AppServiceHTTPLogs", "AppServiceConsoleLogs", "AppServiceAppLogs", "AppServiceFileAuditLogs", "AppServiceAuditLogs", "AppServiceIPSecAuditLogs", "AppServicePlatformLogs"]
  }

  functionapp_diag_settings = {
    metrics = "AllMetrics"
    logs    = "FunctionAppLogs"
  }

  site_app_settings = {
    "WEBSITE_DNS_SERVER"     = "168.63.129.16"
    "WEBSITE_VNET_ROUTE_ALL" = "1"
  }

  app_service_settings = {
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "disabled"
    SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    WEBSITE_CONTENTOVERVNET                         = "1"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
  }

  windows_app_settings = {
    XDT_MicrosoftApplicationInsights_Java   = "1"
    XDT_MicrosoftApplicationInsights_NodeJS = "1"
  }

  # Generate a list of App Service Plan
  service_plans = flatten(
    [for key, val in var.sites : {
      # Keys
      key = "${local.service_plan_name}${key}"
      # Resource Reference
      location                   = var.location
      service_plan_name          = "${local.service_plan_name}${key}"
      resource_group_name        = local.site_resource_group_name
      os_type                    = val.os_type
      sku_name                   = try(val.sku_name, "P1v2")
      zone_balancing_enabled     = try(val.zone_balancing_enabled, false)
      log_analytics_workspace_id = val.log_analytics_workspace_id
      }
    ]
  )

  # Generate a list of App Services
  applications = flatten(
    [for key, val in var.sites :
      [for subkey, subval in val.applications : {
        # Keys
        key                          = key
        subkey                       = subkey
        location                     = var.location
        service_plan_name            = "${local.service_plan_name}${key}"
        resource_group_name          = local.site_resource_group_name
        log_analytics_workspace_id   = val.log_analytics_workspace_id
        vnet_resource_group_name     = val.vnet_resource_group_name
        virtual_network_name         = val.virtual_network_name
        integration_subnet_name      = val.integration_subnet_name
        private_endpoint_subnet_name = val.private_endpoint_subnet_name
        application_resource_type    = subval.application_resource_type
        os_type                      = subval.os_type
        private_dns_zone_id          = try(val.private_dns_zone_id, "None")
        app_settings                 = try(subval.app_settings, "None")
        allowed_origins              = try(subval.allowed_origins, ["*"])
        client_affinity_enabled      = try(subval.client_affinity_enabled, true)
        }
      ]
    ]
  )

  # Generate a list of App Service Slots
  application_slots = flatten(
    [for key, val in var.sites :
      [for subkey, subval in val.app_services :
        [for xkey, xval in subval.slots : {
          # Keys
          key    = key
          subkey = subkey
          xkey   = xkey
          # Resource Reference
          location                       = val.location
          service_plan_name              = "${lower(var.env)}-${val.location}-${val.service_plan_name}"
          appservice_name                = "${lower(var.env)}-${val.location}-${subkey}"
          slot_name                      = xkey
          appservice_resource_group_name = val.resource_group_name
          os_type                        = val.os_type
          vnet_resource_group_name       = val.vnet_resource_group_name
          virtual_network_name           = val.virtual_network_name
          integration_subnet_name        = val.integration_subnet_name
          log_analytics_workspace_id     = val.log_analytics_workspace_id
          private_endpoint_subnet_name   = val.private_endpoint_subnet_name
          private_dns_zone_id            = try(val.private_dns_zone_id, "None")
          app_settings                   = try(subval.app_settings, "None")
          allowed_origins                = try(subval.allowed_origins, ["*"])
          client_affinity_enabled        = try(subval.client_affinity_enabled, true)
          }
        ]
      ]
    ]
  )
}