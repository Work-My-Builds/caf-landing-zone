module "group_role_assignment" {
  for_each = {
    for obj in local.groups : "${obj.group}|${obj.role_identifier}" => obj
  }

  source = "../role_assignments"

  name                  = each.value.role
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = data.azuread_group.group["${each.value.group}|${each.value.role_identifier}"].object_id

  depends_on = [ azurerm_role_definition.role_definition ]
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

  root_scope_resource_id        = local.root_scope_resource_id
  management_group_id           = local.management_group_id
  subscription_id               = local.subscription_id
  prefix                        = var.prefix
  business_code                 = var.business_code
  environment                   = local.environment
  location                      = var.location
  vulnerabilityAssessmentsEmail = var.vulnerabilityAssessmentsEmail
  emailSecurityContact          = var.emailSecurityContact
  policy_definition_depencies   = flatten([for key, data in merge(azurerm_policy_definition.policy_definition, azurerm_policy_set_definition.policy_set_definition) : data.id])
}

module "backup" {
  source = "../management/backup"

  count = var.enable_backup == true ? 1 : 0

  management_group_id = local.management_group_id
  subscription_id     = local.subscription_id
  prefix              = var.prefix
  business_code       = var.business_code
  environment         = local.environment
  location            = var.location
}

module "virtual_network" {
  source = "../core/virtual_network"

  count = var.enable_network == true ? 1 : 0

  root_scope_resource_id     = local.root_scope_resource_id
  management_group_id        = local.management_group_id
  subscription_id            = local.subscription_id
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

  onpremise_gateway_ip           = var.virtual_network.onpremise_gateway_ip
  onpremise_address_space        = var.virtual_network.onpremise_address_space
  onpremise_bgp_peering_settings = var.virtual_network.onpremise_bgp_peering_settings
}