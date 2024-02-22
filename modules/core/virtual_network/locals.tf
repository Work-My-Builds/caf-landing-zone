locals {
  geo_codes      = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))

  vnet_resource_group_name    = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  ddos_name                   = lower("${var.prefix}-${local.resource_codes.resources["DDOS Protection plan"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  virtual_network_name        = lower("${var.prefix}-${local.resource_codes.resources["Virtual network"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  network_security_group_name        = lower("${var.prefix}-${local.resource_codes.resources["Network security group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  route_table_name        = lower("${var.prefix}-${local.resource_codes.resources["Route table"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")

  subnet_prefix = lower("${var.prefix}-${local.resource_codes.resources["Virtual network subnet"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}")

  address_cidr = split("/", var.network_address_space[0])[1]

  hub_subnets = [
    "AzureFirewallSubnet:24",
    "AzureBastionSubnet:24",
    "DomainController:24",
    "GatewaySubnet:24"
  ]
  network_subnet = var.enable_hub_network == true ? local.hub_subnets : var.subnets

  subnet_cidrs = [
    for cidr in local.network_subnet : tonumber(split(":", cidr)[1] - local.address_cidr)
  ]
  subnets = flatten(
    [for sub in toset(local.network_subnet) : {
      name             = split(":", sub)[0] == "AzureFirewallSubnet" || split(":", sub)[0] == "AzureBastionSubnet" || split(":", sub)[0] == "DomainController" || split(":", sub)[0] == "GatewaySubnet" ? split(":", sub)[0] : lower("${local.subnet_prefix}-${lower(split(":", sub)[0])}")
      address_prefixes = cidrsubnets(var.network_address_space[0], local.subnet_cidrs[*]...)[index(local.network_subnet, sub)]
      }
    ]
  )

  delegation = {

    name = "delegation"

    service_delegation = {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  peering = flatten(
    [for peer in toset(var.peered_vnet_id) :
      {
        peer                         = compact(split(":", peer))[1]
        peer_to_hub                  = lower(compact(split(":", peer))[0])
        peering_id                   = compact(split(":", peer))[1]
        peering_name                 = split("/", compact(split(":", peer))[1])[8]
        allow_virtual_network_access = true
        allow_forwarded_traffic      = true
        allow_gateway_transit        = var.enable_hub_network == true ? true : false
        use_remote_gateways          = var.enable_hub_network == true ? false : (lower(compact(split(":", peer))[0]) == "hub" ? true : false)
      }
    ]
  )
}