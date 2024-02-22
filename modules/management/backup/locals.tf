locals {
  geo_codes      = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))

  data_resource_group_name    = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-03")
  user_assigned_identity_name = lower("${var.prefix}-${local.resource_codes.resources["Managed identity"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-03")
  key_vault_name              = lower("${var.prefix}-${local.resource_codes.resources["Key vault"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-03")
  storage_account_name        = lower("${var.prefix}${local.resource_codes.resources["Storage account"].abbreviation}${local.geo_codes.codes[var.location].shortName}${var.business_code}${var.environment}03")
  backup_vault_name           = lower("${var.prefix}-${local.resource_codes.resources["Backup vault"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-03")
  recovery_service_vault_name = lower("${var.prefix}-${local.resource_codes.resources["Recovery Services vault"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-03")

  role_definitions = [
    "Backup Contributor",
    "Storage Account Contributor",
    "Virtual Machine Contributor"
  ]
}