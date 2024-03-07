locals {
  data_sources = jsondecode(file(".${path.root}/assets/datacollectionrules.json")).data_sources

  geo_codes      = jsondecode(templatefile(".${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile(".${path.root}/assets/resource-codes.json", {}))

  storage_environment          = replace(var.environment, "-", "")
  mon_resource_group_name      = upper("${local.resource_codes.resources["Resource Group"].abbreviation}-mon-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  log_analytics_workspace_name = lower("${local.resource_codes.resources["Log Analytics Workspace"].abbreviation}-mon-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  user_assigned_identity_name  = lower("${local.resource_codes.resources["Managed Identity"].abbreviation}-mon-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  data_collection_rule_name    = lower("${local.resource_codes.resources["Azure Monitor Data Collection Rules"].abbreviation}-mon-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  storage_account_name         = lower("${local.resource_codes.resources["Storage Account"].abbreviation}mon${local.geo_codes.codes[var.location].shortName}${local.storage_environment}01")

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