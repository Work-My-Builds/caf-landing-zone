# Get the current client configuration from the AzureRM provider

# Obtain client configuration from the un-aliased provider
data "azurerm_client_config" "core" {
  provider = azurerm
}

# Obtain client configuration from the "management" provider
data "azurerm_client_config" "management" {
  provider = azurerm.management
}

# Obtain client configuration from the "connectivity" provider
data "azurerm_client_config" "connectivity" {
  provider = azurerm.connectivity
}

# Logic to handle 1-3 platform subscriptions as available

locals {
  subscription_id_connectivity = coalesce(var.subscription_id_connectivity, data.azurerm_client_config.connectivity.subscription_id)
  subscription_id_identity     = coalesce(var.subscription_id_identity, data.azurerm_client_config.core.subscription_id)
  subscription_id_management   = coalesce(var.subscription_id_management, data.azurerm_client_config.management.subscription_id)
}

# The following module declarations act to orchestrate the
# independently defined module instances for core,
# connectivity and management resources

module "management" {
  source = "./modules/management"

  email_security_contact     = var.email_security_contact
  log_retention_in_days      = var.log_retention_in_days
  management_resources_tags  = var.management_resources_tags
  primary_location           = var.primary_location
  root_id                    = var.root_id
  subscription_id_management = local.subscription_id_management
}

module "core" {
  source = "./modules/core"

  configure_connectivity_resources = module.connectivity.configuration
  configure_management_resources   = module.management.configuration
  primary_location                 = var.primary_location
  root_id                          = var.root_id
  root_name                        = var.root_name
  secondary_location               = var.secondary_location
  subscription_id_connectivity     = local.subscription_id_connectivity
  subscription_id_identity         = local.subscription_id_identity
  subscription_id_management       = local.subscription_id_management
  landing_zone_subscriptions = [
    "a83ba213-45fa-4153-bd33-56a51d640d35",
  ]
}