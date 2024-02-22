locals {
  data_sources = jsondecode(file("${path.root}/assets/datacollectionrules.json")).data_sources

  geo_codes      = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))

  mon_resource_group_name      = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-02")
  log_analytics_workspace_name = lower("${var.prefix}-${local.resource_codes.resources["Log Analytics workspace"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-02")
  user_assigned_identity_name  = lower("${var.prefix}-${local.resource_codes.resources["Managed identity"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-02")
  data_collection_rule_name    = lower("${var.prefix}-${local.resource_codes.resources["Azure Monitor data collection rules"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-02")
  storage_account_name         = lower("${var.prefix}${local.resource_codes.resources["Storage account"].abbreviation}${local.geo_codes.codes[var.location].shortName}${var.business_code}${var.environment}02")

  role_definitions = [
    "Monitoring Contributor",
    "Log Analytics Contributor",
    "Security Admin",
    "Contributor",
    "SQL Security Manager",
    "SQL Server Contributor",
    "Storage Account Contributor",
    "SQL Managed Instance Contributor"
  ]
}