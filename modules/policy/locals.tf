locals {
  root_scope_resource_id = "/providers/Microsoft.Management/managementGroups/${var.root_scope_resource_id}"
  management_group_id    = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  subscription_id        = "/subscriptions/${var.subscription_id}"

  environment = lower(var.environment) == "development" ? "dev" : (lower(var.environment) == "stage" ? "stg" : (lower(var.environment) == "test" ? "tst" : (lower(var.environment) == "production" ? "prd" : (lower(var.environment) == "prod" ? "prd" : lower(var.environment)))))

  groups = flatten(
    [for group, role in var.role_assignments.group_data :
      {
        role            = role
        role_identifier = replace(role, " ", "_")
        group           = group
      }
    ]
  )

  users = flatten(
    [for user, role in var.role_assignments.user_data :
      {
        role            = role
        role_identifier = replace(role, " ", "_")
        user            = user
      }
    ]
  )

  role_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/role_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", local.root_scope_resource_id))
    ]
  )

  roles = [
    "Application-Owners",
    "Network-Management",
    "Network-Subnet-Contributor",
    "Security-Operations",
    "Subscription-Owner"
  ]

  policy_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", local.root_scope_resource_id))
    ]
  )

  policy_set_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_set_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", local.root_scope_resource_id))
    ]
  )

  policy_assignments = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_assignments/*.json") :
      jsondecode(templatefile("${path.root}/${file}", {
        root_scope_resource_id    = "${local.root_scope_resource_id}"
        current_scope_resource_id = "${local.subscription_id}"
        default_location          = "${var.location}"
      }))
    ]
  )

  production_env = [
    "prd",
    "prod",
    "production"
  ]

  monitoring_policy_assignments = [
    var.enable_monitoring != true ? "Deploy-ASC-Monitoring" : "",
    var.enable_monitoring != true ? "Deploy-AzActivity-Log" : "",
    var.enable_monitoring != true ? "Deploy-AzSqlDb-Auditing" : "",
    var.enable_monitoring != true ? "Deploy-MDEndpoints" : "",
    var.enable_monitoring != true ? "Deploy-MDFC-Config" : "",
    var.enable_monitoring != true ? "Deploy-MDFC-OssDb" : "",
    var.enable_monitoring != true ? "Deploy-MDFC-SqlAtp" : "",
    var.enable_monitoring != true ? "Deploy-SQL-Security" : "",
    var.enable_monitoring != true ? "Deploy-VM-Monitoring" : "",
    var.enable_monitoring != true ? "Deploy-VMSS-Monitoring" : "",
    contains(local.production_env, lower(local.environment)) ? "Deny-UnmanagedDisk" : ""
  ]
  policy_assignment_to_exclude = concat(compact(var.exclude_policy_assignments), compact(local.monitoring_policy_assignments))

  subscription_policy_assignments = flatten(
    [for assign in local.policy_assignments :
      {
        name                   = assign.name
        location               = assign.location
        policy_definition_id   = assign.properties.policyDefinitionId
        display_name           = assign.properties.displayName
        description            = assign.properties.description
        non_compliance_message = try(assign.properties.nonComplianceMessages, "None") != "None" ? assign.properties.nonComplianceMessages[0] : {}
        parameters             = assign.properties.parameters != {} ? jsonencode(assign.properties.parameters) : null
        scope                  = assign.properties.scope
        identity               = assign.identity.type != "None" ? assign.identity : {}
      } if var.enable_policy_assignments != false && !contains(local.policy_assignment_to_exclude, assign.name)
    ]
  )
}