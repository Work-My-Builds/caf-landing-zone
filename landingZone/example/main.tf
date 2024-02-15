#resource "azurerm_resource_group" "rg" {
#  #provider = azurerm.identity
#  name     = "Monitoring"
#  location = "eastus"
#}
#
#resource "azurerm_user_assigned_identity" "user_assigned_identity" {
#  #provider            = azurerm.identity
#  location            = "eastus"
#  name                = "Monitoring-Identity"
#  resource_group_name = azurerm_resource_group.rg.name
#}
#
#module "role_assignment1" {
#  source = "../../role_assignments"
#
#  name                  = "Log Analytics Contributor"
#  scope                 = "/providers/Microsoft.Management/managementGroups/    "
#  role_definition_scope = "/providers/Microsoft.Management/managementGroups/    "
#  principal_id          = azurerm_user_assigned_identity.user_assigned_identity.principal_id
#
#  #providers = {
#  #  azurerm = azurerm.identity
#  #}
#}
#
#module "role_assignment2" {
#  source = "../../role_assignments"
#
#  name                  = "Monitoring Contributor"
#  scope                 = "/providers/Microsoft.Management/managementGroups/    "
#  role_definition_scope = "/providers/Microsoft.Management/managementGroups/    "
#  principal_id          = azurerm_user_assigned_identity.user_assigned_identity.principal_id
#
#  #providers = {
#  #  azurerm = azurerm.identity
#  #}
#}
#
#module "set_subscription1" {
#  source = "../"
#
#  management_group_name      = "testmgmgroup"
#  subscription_id            = "subscription_id"
#  policy_assignment_identity = azurerm_user_assigned_identity.user_assigned_identity.id
#  location                   = "eastus"
#  owner                      = "owner upn"
#}

#module "set_subscription2" {
#  source = "../"
#
#  management_group_name      = "management_group_name"
#  subscription_id            = "subscription_id"
#  policy_assignment_identity = azurerm_user_assigned_identity.user_assigned_identity.id
#  location                   = "location"
#  owner                      = ""
#}


module "set_subscription" {
  #for_each = {
  #  for sub in local.subscription_object: sub.subcription_name => sub
  #}

  source = "../"

  subscription_name     = local.subscription1.subcription_name
  environment           = local.subscription1.environment
  management_group_name = local.subscription1.management_group_name
  subscription_id       = local.subscription1.subscription_id
  users                 = local.subscription1.users
  location              = var.location
  prefix                = var.prefix
  enable_network        = local.subscription1.enable_network
  network_address_space = local.subscription1.network_address_space
}