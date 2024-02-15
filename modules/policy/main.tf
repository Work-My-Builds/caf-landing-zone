# Create Azure Role Defition
resource "azurerm_role_definition" "role_definition" {
  for_each = {
    for role in local.role_definitions : role.properties.roleName => role
    if var.enable_role_definitions != false
  }

  name        = each.value.properties.roleName
  scope       = var.management_group_id
  description = each.value.properties.description

  permissions {
    actions          = each.value.properties.permissions[0].actions
    not_actions      = each.value.properties.permissions[0].notActions
    data_actions     = each.value.properties.permissions[0].dataActions
    not_data_actions = each.value.properties.permissions[0].notDataActions
  }
}

# Create Azure Policy Defition
resource "azurerm_policy_definition" "policy_definition" {
  for_each = {
    for def in local.policy_definitions : def.name => def
    if var.enable_policy_definitions != false
  }
  name                = each.value.name
  policy_type         = each.value.properties.policyType
  mode                = title(each.value.properties.mode)
  display_name        = each.value.properties.displayName
  description         = each.value.properties.description
  management_group_id = var.management_group_id

  metadata    = jsonencode(each.value.properties.metadata)
  policy_rule = jsonencode(each.value.properties.policyRule)
  parameters  = jsonencode(each.value.properties.parameters) != "{}" ? "${jsonencode(each.value.properties.parameters)}" : null
}

# Create Azure Policy Set Defition
resource "azurerm_policy_set_definition" "policy_set_definition" {
  for_each = {
    for def in local.policy_set_definitions : def.name => def
    if var.enable_policy_definitions != false
  }
  name                = each.value.name
  display_name        = each.value.properties.displayName
  policy_type         = each.value.properties.policyType
  description         = each.value.properties.description
  management_group_id = var.management_group_id

  parameters = jsonencode(each.value.properties.parameters) != "{}" ? "${jsonencode(each.value.properties.parameters)}" : null

  dynamic "policy_definition_reference" {
    for_each = each.value.properties.policyDefinitions
    iterator = pdr

    content {
      policy_definition_id = replace(pdr.value.policyDefinitionId, "$${root_scope_resource_id}", var.management_group_id)
      reference_id         = pdr.value.policyDefinitionReferenceId
      parameter_values     = jsonencode(pdr.value.parameters)
    }
  }

  depends_on = [
    azurerm_policy_definition.policy_definition
  ]
}

# Create Azure Policy Assignment
resource "azurerm_subscription_policy_assignment" "policy_assignment" {
  for_each = {
    for assign in local.subscription_policy_assignments : assign.name => assign
  }

  name                 = each.value.name
  location             = var.location
  policy_definition_id = each.value.policy_definition_id
  subscription_id      = each.value.scope
  display_name         = each.value.display_name
  description          = each.value.description
  parameters           = each.value.parameters

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message
    iterator = ncm

    content {
      content = ncm.value
    }
  }

  dynamic "identity" {
    for_each = each.value.identity

    content {
      type         = var.enable_monitoring == true ? "UserAssigned" : "SystemAssigned"
      identity_ids = var.enable_monitoring == true ? [module.monitoring[0].identity_id] : null
    }
  }

  depends_on = [
    azurerm_policy_definition.policy_definition,
    azurerm_policy_set_definition.policy_set_definition
  ]
}