resource "azurerm_role_definition" "role_definition" {
  for_each = {
    for role in local.role_definitions : role.properties.roleName => role
  }

  name        = each.value.properties.roleName
  scope       = contains(split("/", var.root_scope_resource_id), "Microsoft.Management") == true ? var.root_scope_resource_id : null
  description = each.value.properties.description

  permissions {
    actions          = each.value.properties.permissions[0].actions
    not_actions      = each.value.properties.permissions[0].notActions
    data_actions     = each.value.properties.permissions[0].dataActions
    not_data_actions = each.value.properties.permissions[0].notDataActions
  }
}

resource "azurerm_policy_definition" "policy_definition" {
  for_each = {
    for def in local.policy_definitions : def.name => def
  }
  name                = each.value.name
  policy_type         = each.value.properties.policyType
  mode                = title(each.value.properties.mode)
  display_name        = each.value.properties.displayName
  description         = each.value.properties.description
  management_group_id = contains(split("/", var.root_scope_resource_id), "Microsoft.Management") == true ? var.root_scope_resource_id : null

  metadata    = jsonencode(each.value.properties.metadata)
  policy_rule = jsonencode(each.value.properties.policyRule)
  parameters  = jsonencode(each.value.properties.parameters) != "{}" ? "${jsonencode(each.value.properties.parameters)}" : null
}

resource "azurerm_policy_set_definition" "policy_set_definition" {
  for_each = {
    for def in local.policy_set_definitions : def.name => def
  }
  name                = each.value.name
  display_name        = each.value.properties.displayName
  policy_type         = each.value.properties.policyType
  description         = each.value.properties.description
  management_group_id = contains(split("/", var.root_scope_resource_id), "Microsoft.Management") == true ? var.root_scope_resource_id : null

  parameters = jsonencode(each.value.properties.parameters) != "{}" ? "${jsonencode(each.value.properties.parameters)}" : null

  dynamic "policy_definition_reference" {
    for_each = each.value.properties.policyDefinitions
    iterator = pdr

    content {
      policy_definition_id = replace(pdr.value.policyDefinitionId, "$${root_scope_resource_id}", var.root_scope_resource_id)
      reference_id         = pdr.value.policyDefinitionReferenceId
      parameter_values     = jsonencode(pdr.value.parameters)
    }
  }

  depends_on = [
    azurerm_policy_definition.policy_definition
  ]
}

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
      type         = "UserAssigned"
      identity_ids = [var.identity]
    }
  }

  depends_on = [
    azurerm_policy_definition.policy_definition,
    azurerm_policy_set_definition.policy_set_definition
  ]
}