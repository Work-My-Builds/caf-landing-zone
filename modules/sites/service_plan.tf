resource "azurerm_resource_group" "site_rg" {
  name     = local.site_resource_group_name
  location = var.location
}

resource "azurerm_service_plan" "plan" {
  for_each = {
    for plan in local.service_plans : plan.key => plan
  }

  name                   = each.value.service_plan_name
  resource_group_name    = azurerm_resource_group.site_rg.name
  location               = azurerm_resource_group.site_rg.location
  os_type                = each.value.os_type
  sku_name               = each.value.sku_name
  zone_balancing_enabled = each.value.zone_balancing_enabled
}



resource "azurerm_monitor_diagnostic_setting" "plan_diag" {
  for_each = {
    for diag in local.service_plans : diag.key => diag
  }

  name                       = "${each.value.service_plan_name}-diag"
  target_resource_id         = azurerm_service_plan.plan[each.value.service_plan_name].id
  log_analytics_workspace_id = each.value.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
  }
}