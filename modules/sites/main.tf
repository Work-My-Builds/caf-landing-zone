resource "azurerm_application_insights" "appinsight" {
  for_each = {
    for appinsight in local.service_plans : appinsight.key => appinsight
  }

  name                = "${each.value.service_plan_name}-app-insight"
  resource_group_name = azurerm_resource_group.site_rg.name
  location            = azurerm_resource_group.site_rg.location
  application_type    = try(each.value.application_type, "web")
  retention_in_days   = try(each.value.retention_in_days, 90)
  sampling_percentage = try(each.value.sampling_percentage, 0)
  disable_ip_masking  = try(each.value.disable_ip_masking, false)
  workspace_id        = each.value.log_analytics_workspace_id
}