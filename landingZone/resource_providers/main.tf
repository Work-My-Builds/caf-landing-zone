resource "azurerm_resource_provider_registration" "provider_registration" {
  for_each = toset(local.resource_providers)

  name = each.key
}