locals {
  geo_codes      = jsondecode(templatefile(".${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile(".${path.root}/assets/resource-codes.json", {}))
  private_dns_zones_by_services = jsondecode(templatefile(".${path.root}/assets/private_links.json",
    {
      location          = var.location
      location_geo_code = local.geo_codes.codes[var.location].shortName
    }
  ))

  virtual_network_gateway_name    = lower("${local.resource_codes.resources["Virtual Network Gateway"].abbreviation}-net-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  local_network_gateway_name      = lower("${local.resource_codes.resources["Local Network Gateway"].abbreviation}-net-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  firewall_name                   = lower("${local.resource_codes.resources["Firewall"].abbreviation}-net-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  firewall_policy_name            = lower("${local.resource_codes.resources["Firewall Policy"].abbreviation}-net-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  vpn_public_ip_address_name      = lower("${local.resource_codes.resources["Public IP Address"].abbreviation}-net-${local.geo_codes.codes[var.location].shortName}-${var.environment}01")
  firewall_public_ip_address_name = lower("${local.resource_codes.resources["Public IP Address"].abbreviation}-net-${local.geo_codes.codes[var.location].shortName}-${var.environment}02")

  private_dns_zones = flatten(
    [for dns in toset(local.private_dns_zones_by_services.private_dns_zones) :
      {
        dns                   = dns
        private_dns_zone_name = dns
      } if !startswith(dns, "_")
    ]
  )
}