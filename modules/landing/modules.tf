module "group_role_assignment" {
  for_each = {
    for obj in local.groups : "${obj.group}|${obj.role_identifier}" => obj
  }

  source = "git::https://dev.azure.com/sargentlundy/SargentLundy_DevOps/_git/Terraform_Modules//role_assignments"

  name                  = each.value.role
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = data.azuread_group.group["${each.value.group}|${each.value.role_identifier}"].object_id
}

module "user_role_assignment" {
  for_each = {
    for obj in local.users : "${obj.user}|${obj.role_identifier}" => obj
  }

  source = "git::https://dev.azure.com/sargentlundy/SargentLundy_DevOps/_git/Terraform_Modules//role_assignments"

  name                  = each.value.role
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = data.azuread_user.user["${each.value.user}|${each.value.role_identifier}"].object_id
}

module "role_assignment" {
  source = "git::https://dev.azure.com/sargentlundy/SargentLundy_DevOps/_git/Terraform_Modules//role_assignments"

  for_each = var.mon_identity_id != "" ? toset(local.identity_role_definitions) : []

  name                  = each.value
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = var.mon_identity_principal_id
}

module "monitoring" {
  source = "git::https://dev.azure.com/sargentlundy/SargentLundy_DevOps/_git/Terraform_Modules//management/monitoring"

  count = var.enable_monitoring == true ? 1 : 0

  subscription_id               = azurerm_management_group_subscription_association.mg_subscription_association.subscription_id
  environment                   = local.environment
  location                      = var.location
  vulnerabilityAssessmentsEmail = var.vulnerabilityAssessmentsEmail
  emailSecurityContact          = var.emailSecurityContact
}

module "backup" {
  source = "git::https://dev.azure.com/sargentlundy/SargentLundy_DevOps/_git/Terraform_Modules//management/backup"

  count = var.enable_backup == true ? 1 : 0

  subscription_id = azurerm_management_group_subscription_association.mg_subscription_association.subscription_id
  environment     = local.environment
  location        = var.location
}

module "virtual_network" {
  source = "git::https://dev.azure.com/sargentlundy/SargentLundy_DevOps/_git/Terraform_Modules//core/virtual_network"

  count = var.enable_network == true ? 1 : 0

  subscription_id            = azurerm_management_group_subscription_association.mg_subscription_association.subscription_id
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
  source = "git::https://dev.azure.com/sargentlundy/SargentLundy_DevOps/_git/Terraform_Modules//core/virtual_network_gateway"

  count = var.enable_hub_network == true ? 1 : 0

  environment              = local.environment
  location                 = var.location
  vnet_id                  = module.virtual_network[0].vnet_id
  subnet_ids               = module.virtual_network[0].subnet_id
  vpn_client_configuration = var.virtual_network.vpn_client_configuration
  onpremise_gateway_ip     = var.virtual_network.onpremise_gateway_ip
  onpremise_address_space  = var.virtual_network.onpremise_address_space
  #onpremise_bgp_peering_settings = var.virtual_network.onpremise_bgp_peering_settings
  log_analytics_workspace_id = var.enable_monitoring == true ? module.monitoring[0].log_analytics_workspace_id : ""
}