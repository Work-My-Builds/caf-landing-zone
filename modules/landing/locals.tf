locals {
  geo_codes                    = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes               = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))
  root_scope_resource_id       = "/providers/Microsoft.Management/managementGroups/${var.root_scope_resource_id}"
  management_group_id          = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  subscription_id              = "/subscriptions/${var.subscription_id}"
  environment                  = lower(var.environment) == "development" ? "dev" : (lower(var.environment) == "stage" ? "stg" : (lower(var.environment) == "test" ? "tst" : (lower(var.environment) == "production" ? "prd" : (lower(var.environment) == "prod" ? "prd" : lower(var.environment)))))
  mon_resource_group_name      = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-02")
  log_analytics_workspace_name = lower("${var.prefix}-${local.resource_codes.resources["Log Analytics workspace"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-02")
  storage_account_name         = lower("${var.prefix}${local.resource_codes.resources["Storage account"].abbreviation}${local.geo_codes.codes[var.location].shortName}${var.business_code}${local.environment}02")

  log_analytics_workspace_id = "${local.subscription_id}/resourceGroups/${local.mon_resource_group_name}providers/Microsoft.OperationalInsights/workspaces/${local.log_analytics_workspace_name}"
  storage_account_id         = "${local.subscription_id}/resourceGroups/${local.mon_resource_group_name}providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"

  backup_policy_definition_id   = "/providers/Microsoft.Authorization/policyDefinitions/09ce66bc-1220-4153-8104-e3f51c936913"
  backup_display_name           = "Configure backup on virtual machines without a given tag to an existing recovery services vault in the same location"
  backup_description            = "Enforce backup for all virtual machines by backing them up to an existing central recovery services vault in the same location and subscription as the virtual machine. Doing this is useful when there is a central team in your organization managing backups for all resources in a subscription. You can optionally exclude virtual machines containing a specified tag to control the scope of assignment. See https://aka.ms/AzureVMCentralBackupExcludeTag."
  backup_non_compliance_message = "Backup on virtual machines without a given tag should be configured to an existing recovery services vault with specified backup policy or default policy."

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

  core_policy_assignments = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_assignments/core/*.json") :
      jsondecode(templatefile("${path.root}/${file}", {
        root_scope_resource_id    = "${local.root_scope_resource_id}"
        current_scope_resource_id = "${local.subscription_id}"
        default_location          = "${var.location}"
      }))
    ]
  )

  monitoring_policy_assignments = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_assignments/monitoring/*.json") :
      jsondecode(templatefile("${path.root}/${file}", {
        root_scope_resource_id            = local.root_scope_resource_id
        current_scope_resource_id         = local.subscription_id
        default_location                  = var.location
        emailSecurityContact              = var.emailSecurityContact
        ascExportResourceGroupLocation    = var.location
        vulnerabilityAssessmentsEmail     = var.vulnerabilityAssessmentsEmail
        ascExportResourceGroupName        = var.enable_backup == true ? local.mon_resource_group_name : var.ascExportResourceGroupName
        logAnalyticWorkspaceID            = var.enable_backup == true ? local.log_analytics_workspace_id : var.logAnalyticWorkspaceID
        vulnerabilityAssessmentsStorageID = var.enable_backup == true ? local.storage_account_id : var.vulnerabilityAssessmentsStorageID
      }))
    ]
  )

  production_env = [
    "prd",
    "prod",
    "production"
  ]

  monitoring_policy_exclusion = [
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
  policy_assignment_to_exclude = concat(compact(var.exclude_policy_assignments), compact(local.monitoring_policy_exclusion))

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

  core_subscription_policy_assignments = flatten(
    [for assign in local.core_policy_assignments :
      {
        name                   = assign.name
        location               = assign.location
        policy_definition_id   = assign.properties.policyDefinitionId
        display_name           = assign.properties.displayName
        description            = assign.properties.description
        non_compliance_message = try(assign.properties.nonComplianceMessages, "None") != "None" ? assign.properties.nonComplianceMessages[0] : {}
        parameters             = assign.properties.parameters != {} ? jsonencode(assign.properties.parameters) : null
        scope                  = assign.properties.scope
      } if var.enable_hub_network != true && !contains(var.exclude_policy_assignments, assign.name)
    ]
  )

  monitoring_subscription_policy_assignments = flatten(
    [for assign in local.monitoring_policy_assignments :
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
      } if var.enable_monitoring == true && !contains(var.exclude_policy_assignments, assign.name)
    ]
  )
}