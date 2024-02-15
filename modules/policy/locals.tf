locals {
  role_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/role_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", var.management_group_id))
    ]
  )

  policy_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", var.management_group_id))
    ]
  )

  policy_set_definitions = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_set_definitions/*.json") :
      jsondecode(replace(file("${path.root}/${file}"), "$${root_scope_resource_id}", var.management_group_id))
    ]
  )

  policy_assignments = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_assignments/*.json") :
      jsondecode(templatefile("${path.root}/${file}", {
        root_scope_resource_id            = "${var.management_group_id}"
        current_scope_resource_id         = "${var.subscription_id}"
        default_location                  = "${var.location}"
        logAnalyticWorkspaceID            = "${var.logAnalyticWorkspaceID}"
        emailSecurityContact              = "${var.emailSecurityContact}"
        ascExportResourceGroupName        = "${var.ascExportResourceGroupName}"
        ascExportResourceGroupLocation    = "${var.location}"
        vulnerabilityAssessmentsEmail     = jsonencode(var.vulnerabilityAssessmentsEmail)
        vulnerabilityAssessmentsStorageID = "${var.vulnerabilityAssessmentsStorageID}"
        BudgetAmount                      = "${var.BudgetAmount}"
        BudgetContactEmails               = jsonencode(var.BudgetContactEmails)
      }))
    ]
  )

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
      } if var.enable_policy_assignments != false
    ]
  )
}