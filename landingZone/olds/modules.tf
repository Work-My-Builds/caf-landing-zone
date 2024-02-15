module "resource_providers" {
  source          = "./resource_providers"
  subscription_id = var.subscription_id
}

module "monitoring_core" {
  source          = "./monitoring_core"
  subscription_id = var.subscription_id
}

module "owner_role_assignment" {
  source = "../role_assignments"

  name                  = "Owner"
  scope                 = data.azurerm_subscription.subscription.id
  role_definition_scope = data.azurerm_subscription.subscription.id
  principal_id          = data.azuread_user.owner_user.object_id
}

module "policy_assignments" {
  source = "../policy_assignments"

  location = var.location
  policy_assignments = [
    #{
    #  policy_definition_id = "/providers/Microsoft.Management/managementGroups/e849153d-2958-41f5-b4d3-778b890e9fd2/providers/Microsoft.Authorization/policySetDefinitions/Deploy-Diagnostics-To-LogAnalytics"
    #  identity_id          = var.policy_assignment_identity
    #  parameters           = <<PARAMS
    #    {
    #      "logAnalytics": {
    #        "value": "${module.monitoring_core.oms_id}"
    #      }
    #    }
    #  PARAMS
    #
    #  management_group_id = []
    #  subscription_id = [
    #    data.azurerm_subscription.subscription.id
    #  ]
    #  resource_group_id = []
    #  resource_id       = []
    #},
    {
      policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/924bfe3a-762f-40e7-86dd-5c8b95eb09e6"
      identity_id          = var.policy_assignment_identity
      parameters           = <<PARAMS
        {
          "bringYourOwnUserAssignedManagedIdentity": {
            "value": true
          },
          "userAssignedManagedIdentityResourceGroup": {
            "value": "${module.monitoring_core.resource_group_name}"
          },
          "userAssignedMannagedIdentityName": {
            "value": "${module.monitoring_core.user_assigned_identity_name}"
          },
          "dcrResourceId": {
            "value": "${module.monitoring_core.drc_id}"
          },
          "enableProcessesAndDependencies": {
            "value": true
          }
        }
      PARAMS

      management_group_id = []
      subscription_id = [
        data.azurerm_subscription.subscription.id
      ]
      resource_group_id = []
      resource_id       = []
    }
  ]
}

/*module "resource_providers" {
  for_each = {
    for rp in var.subscription_landing: rp.key => rp
  }

  source = "./resource_providers"
  subscription_id = data.azurerm_subscription.subscription[each.key].subscription_id
}

module "monitoring_core" {
  for_each = {
    for mon in var.subscription_landing: mon.key => mon
  }

  source = "./monitoring_core"
  subscription_id = data.azurerm_subscription.subscription[each.key].subscription_id
}

module "policy_assignments" {
  for_each = {
    for pol in var.subscription_landing: pol.key => pol
  }

  source = "git@github.com:vumc-cloud/ECS-Terraform-Modules//policy_assignments?ref=1.7"

  location = each.value.location
  policy_assignments = [
    {
      policy_definition_id = "/providers/Microsoft.Management/managementGroups/e849153d-2958-41f5-b4d3-778b890e9fd2/providers/Microsoft.Authorization/policySetDefinitions/Deploy-Diagnostics-To-LogAnalytics"
      identity_id          = each.value.policy_assignment_identity
      parameters           = <<PARAMS
        {
          "logAnalytics": {
            "value": "${module.monitoring_core[each.key].oms_id}"
          }
        }
      PARAMS

      management_group_id = []
      subscription_id = [
        data.azurerm_subscription.subscription[each.key].id
      ]
      resource_group_id = []
      resource_id       = []
    },
    {
      policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/924bfe3a-762f-40e7-86dd-5c8b95eb09e6"
      identity_id          = each.value.policy_assignment_identity
      parameters           = <<PARAMS
        {
          "bringYourOwnUserAssignedManagedIdentity": {
            "value": false
          },
          "dcrResourceId": {
            "value": "${module.monitoring_core[each.key].drc_id}"
          },
          "enableProcessesAndDependencies": {
            "value": true
          }
        }
      PARAMS

      management_group_id = []
      subscription_id = [
        data.azurerm_subscription.subscription[each.key].id
      ]
      resource_group_id = []
      resource_id       = []
    }
  ]
}*/