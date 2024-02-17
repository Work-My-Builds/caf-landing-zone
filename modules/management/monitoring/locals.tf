locals {
  data_sources = jsondecode(file("${path.root}/assets/datacollectionrules.json")).data_sources

  geo_codes      = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))
  environment    = lower(terraform.workspace) == "development" ? "dev" : (lower(terraform.workspace) == "stage" ? "stg" : (lower(terraform.workspace) == "test" ? "tst" : (lower(terraform.workspace) == "production" ? "prd" : (lower(terraform.workspace) == "prod" ? "prd" : lower(terraform.workspace)))))

  mon_resource_group_name      = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  log_analytics_workspace_name = lower("${var.prefix}-${local.resource_codes.resources["Log Analytics workspace"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  user_assigned_identity_name  = lower("${var.prefix}-${local.resource_codes.resources["Managed identity"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  data_collection_rule_name    = lower("${var.prefix}-${local.resource_codes.resources["Azure Monitor data collection rules"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  storage_account_name         = lower("${var.prefix}${local.resource_codes.resources["Storage account"].abbreviation}${local.geo_codes.codes[var.location].shortName}${var.business_code}${local.environment}01")

  role_definitions = [
    "Monitoring Contributor",
    "Log Analytics Contributor",
    "Security Admin",
    "Contributor",
    "SQL Security Manager",
    "SQL Server Contributor",
    "Storage Account Contributor",
    "SQL Managed Instance Contributor"
  ]

  policy_assignments = flatten(
    [for file in fileset("${path.root}", "archetypes/policy_assignments/monitoring/*.json") :
      jsondecode(templatefile("${path.root}/${file}", {
        root_scope_resource_id            = "${var.management_group_id}"
        current_scope_resource_id         = "${var.subscription_id}"
        default_location                  = "${var.location}"
        logAnalyticWorkspaceID            = "${data.azurerm_subscription.subscription.id}/resourceGroups/${local.mon_resource_group_name}/providers/Microsoft.OperationalInsights/workspaces/${local.log_analytics_workspace_name}"
        emailSecurityContact              = "${var.emailSecurityContact}"
        ascExportResourceGroupName        = "${local.mon_resource_group_name}"
        ascExportResourceGroupLocation    = "${var.location}"
        vulnerabilityAssessmentsEmail     = "${var.vulnerabilityAssessmentsEmail}"
        vulnerabilityAssessmentsStorageID = "${data.azurerm_subscription.subscription.id}/resourceGroups/${local.mon_resource_group_name}/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
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
      } if !contains(var.policy_assignment_to_exclude, assign.name)
    ]
  )
}