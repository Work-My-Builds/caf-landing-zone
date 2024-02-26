module "group_role_assignment" {
  for_each = {
    for obj in local.groups : "${obj.group}|${obj.role_identifier}" => obj
  }

  source = "../role_assignments"

  name                  = each.value.role
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = data.azuread_group.group["${each.value.group}|${each.value.role_identifier}"].object_id
}

module "user_role_assignment" {
  for_each = {
    for obj in local.users : "${obj.user}|${obj.role_identifier}" => obj
  }

  source = "../role_assignments"

  name                  = each.value.role
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = data.azuread_user.user["${each.value.user}|${each.value.role_identifier}"].object_id
}

module "monitoring" {
  source = "../management/monitoring"

  count = var.enable_monitoring == true ? 1 : 0

  subscription_id               = local.subscription_id
  prefix                        = var.prefix
  business_code                 = var.business_code
  environment                   = local.environment
  location                      = var.location
  vulnerabilityAssessmentsEmail = var.vulnerabilityAssessmentsEmail
  emailSecurityContact          = var.emailSecurityContact
}

module "backup" {
  source = "../management/backup"

  count = var.enable_backup == true ? 1 : 0

  subscription_id = local.subscription_id
  prefix          = var.prefix
  business_code   = var.business_code
  environment     = local.environment
  location        = var.location
}

module "virtual_network" {
  source = "../core/virtual_network"

  count = var.enable_network == true ? 1 : 0

  prefix                     = var.prefix
  business_code              = var.business_code
  environment                = local.environment
  location                   = var.location
  exclude_policy_assignments = local.policy_assignment_to_exclude
  enable_hub_network         = var.enable_hub_network
  subnets                    = var.virtual_network.subnets
  peered_vnet_id             = var.virtual_network.peered_vnet_id
  network_address_space      = var.virtual_network.network_address_space
  network_dns_address        = var.virtual_network.network_dns_address
  ddos_protection_plan_id    = var.virtual_network.ddos_protection_plan_id
}

module "virtual_network_gateway" {
  source = "../core/virtual_network_gateway"

  count = var.enable_hub_network == true ? 1 : 0

  prefix                         = var.prefix
  business_code                  = var.business_code
  environment                    = local.environment
  location                       = var.location
  vnet_id                        = module.virtual_network[0].vnet_id
  subnet_ids                     = module.virtual_network[0].subnet_id
  onpremise_gateway_ip           = var.virtual_network.onpremise_gateway_ip
  onpremise_address_space        = var.virtual_network.onpremise_address_space
  onpremise_bgp_peering_settings = var.virtual_network.onpremise_bgp_peering_settings
  log_analytics_workspace_id     = module.monitoring.log_analytics_workspace_id
  depends_on                     = [module.virtual_network.vnet_id]
}