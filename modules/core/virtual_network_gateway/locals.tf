locals {
  geo_codes      = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))
  environment    = lower(terraform.workspace) == "development" ? "dev" : (lower(terraform.workspace) == "stage" ? "stg" : (lower(terraform.workspace) == "test" ? "tst" : (lower(terraform.workspace) == "production" ? "prd" : (lower(terraform.workspace) == "prod" ? "prd" : lower(terraform.workspace)))))


  virtual_network_gateway_name    = lower("${var.prefix}-${local.resource_codes.resources["Virtual network gateway"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  local_network_gateway_name      = lower("${var.prefix}-${local.resource_codes.resources["Local network gateway"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  firewall_name                   = lower("${var.prefix}-${local.resource_codes.resources["Firewall"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  firewall_policy_name            = lower("${var.prefix}-${local.resource_codes.resources["Firewall policy"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  vpn_public_ip_address_name      = lower("${var.prefix}-${local.resource_codes.resources["Public IP address"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  firewall_public_ip_address_name = lower("${var.prefix}-${local.resource_codes.resources["Public IP address"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-02")
}