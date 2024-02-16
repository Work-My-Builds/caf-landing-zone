locals {
  data_sources = jsondecode(file("${path.root}/assets/datacollectionrules.json")).data_sources

  users = flatten([
    for key, data in var.users : {
      role            = key
      role_identifier = replace(key, " ", "_")
      user            = data
    }
  ])

  geo_codes      = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))
  environment    = lower(terraform.workspace) == "development" ? "dev" : (lower(terraform.workspace) == "stage" ? "stg" : (lower(terraform.workspace) == "test" ? "tst" : (lower(terraform.workspace) == "production" ? "prd" : (lower(terraform.workspace) == "prod" ? "prd" : lower(terraform.workspace)))))

  mon_resource_group_name      = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  log_analytics_workspace_name = lower("${var.prefix}-${local.resource_codes.resources["Log Analytics workspace"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  user_assigned_identity_name  = lower("${var.prefix}-${local.resource_codes.resources["Managed identity"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  data_collection_rule_name    = lower("${var.prefix}-${local.resource_codes.resources["Azure Monitor data collection rules"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  data_resource_group_name    = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-02")
  key_vault_name              = lower("${var.prefix}-${local.resource_codes.resources["Key vault"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  storage_account_name        = lower("${var.prefix}${local.resource_codes.resources["Storage account"].abbreviation}${local.geo_codes.codes[var.location].shortName}${var.business_code}${local.environment}01")
  backup_vault_name           = lower("${var.prefix}-${local.resource_codes.resources["Backup vault"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  recovery_service_vault_name = lower("${var.prefix}-${local.resource_codes.resources["Recovery Services vault"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")

  role_definitions = [
    "Monitoring Contributor",
    "Log Analytics Contributor",
    "Security Admin",
    "Contributor",
    "Network Contributor",
    "SQL Security Manager",
    "SQL Server Contributor",
    "Storage Account Contributor",
    "SQL Managed Instance Contributor"
  ]
}