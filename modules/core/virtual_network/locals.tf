locals {
  geo_codes      = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))
  environment    = lower(terraform.workspace) == "development" ? "dev" : (lower(terraform.workspace) == "stage" ? "stg" : (lower(terraform.workspace) == "test" ? "tst" : (lower(terraform.workspace) == "production" ? "prd" : (lower(terraform.workspace) == "prod" ? "prd" : lower(terraform.workspace)))))


  vnet_resource_group_name = lower("${var.prefix}-${local.resource_codes.resources["Resource group"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  ddos_name                = lower("${var.prefix}-${local.resource_codes.resources["DDOS Protection plan"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")
  virtual_network_name     = lower("${var.prefix}-${local.resource_codes.resources["Virtual network"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}-01")

  subnet_prefix = lower("${var.prefix}-${local.resource_codes.resources["Virtual network subnet"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${local.environment}")
  #subnets = flatten(
  #  [for sub in toset(var.subnets) : {
  #    sub              = lower(split(":", sub)[0])
  #    subnet_name      = lower(split(":", sub)[0]) == "AzureFirewallSubnet" || lower(split(":", sub)[0]) == "AzureFirewallManagementSubnet" || lower(split(":", sub)[0]) == "AzureBastionSubnet" || lower(split(":", sub)[0]) == "GatewaySubnet" ? lower(split(":", sub)[0]) : lower("${local.subnet_prefix}-${lower(split(":", sub)[0])}")
  #    address_prefixes = split(":", sub)[1]
  #    }
  #  ]
  #)

  address_cidr = split("/", var.network_address_space[0])[1]
  subnets = flatten(
    [for sub in toset(var.subnets) : {
      name     = lower(split(":", sub)[0]) == "AzureFirewallSubnet" || lower(split(":", sub)[0]) == "AzureFirewallManagementSubnet" || lower(split(":", sub)[0]) == "AzureBastionSubnet" || lower(split(":", sub)[0]) == "GatewaySubnet" ? lower(split(":", sub)[0]) : lower("${local.subnet_prefix}-${lower(split(":", sub)[0])}")
      new_bits = split(":", sub)[1] - local.address_cidr
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
}