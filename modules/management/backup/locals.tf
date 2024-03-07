locals {
  geo_codes      = jsondecode(templatefile(".${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile(".${path.root}/assets/resource-codes.json", {}))

  storage_environment         = replace(var.environment, "-", "")
  user_assigned_identity_name = lower("${local.resource_codes.resources["Managed Identity"].abbreviation}-backup-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  data_resource_group_name    = upper("${local.resource_codes.resources["Resource Group"].abbreviation}-backup-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  key_vault_name              = lower("${local.resource_codes.resources["Key Vault"].abbreviation}-backup-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  storage_account_name        = lower("${local.resource_codes.resources["Storage Account"].abbreviation}backup${local.geo_codes.codes[var.location].shortName}${local.storage_environment}01")
  recovery_service_vault_name = lower("${local.resource_codes.resources["Recovery Services Vault"].abbreviation}-backup-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  backup_vault_name           = lower("${local.resource_codes.resources["Backup Vault"].abbreviation}-backup-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")

  role_definitions = [
    "Backup Contributor",
    "Storage Account Contributor",
    "Virtual Machine Contributor"
  ]
}