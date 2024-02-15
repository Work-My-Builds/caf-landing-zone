provider "azurerm" {
  skip_provider_registration = true
  features {

  }
}



locals {
  address      = "10.0.0.0/16"
  address_cidr = split("/", local.address)[1]
  netnum = {
    30 = 4
    29 = 8
    28 = 16
    27 = 32
    26 = 64
    25 = 128
    24 = 256
    23 = 512
    22 = 1024
    21 = 2048
    20 = 4096
    19 = 8192
    18 = 16384
    17 = 32768
    16 = 65536
  }
  subnet_objects = [
    "abc:24",
    "def:28",
    "ghi:24",
    "jkl:28"
  ]

  cidrs = [
    for cidr in local.subnet_objects : tonumber(split(":", cidr)[1] - split("/", local.address)[1])
  ]

  subnets = flatten(
    [for sub in toset(local.subnet_objects) : {
      name     = lower(split(":", sub)[0])
      new_bits = split(":", sub)[1] - local.address_cidr
      }
    ]
  )
}

module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = local.address
  networks        = local.subnets
}

output "subnet_address_range" {
  value = module.subnet_addrs
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    for subnet in module.subnet_addrs.networks : subnet.name => subnet
  }

  name                 = each.value.name
  resource_group_name  = "MFALOWORGDEV1"
  virtual_network_name = "testvnet"
  address_prefixes     = [each.value.cidr_block]
}

#output "subnet_address_range" {
#  value = [
#    for sub in azurerm_subnet.subnet: sub.address_prefixes[0]
#  ]
#}

output "subnets" {
  value = join(",", local.cidrs)
}

output "address_prefixes" {
  value = parseint(regex("/(\\d+)$", local.address)[0], 10)
}










#cidrsubnet(local.address, local.address_cidr - (split(":", sub)[1] - local.address_cidr), index(local.subnet_objects, sub))
#index(local.subnet_objects, sub) == 0 ? cidrsubnet(local.address, split(":", sub)[1] - local.address_cidr, index(local.subnet_objects, sub)) : cidrsubnet(local.address, split(":", sub)[1] - local.address_cidr, local.address_cidr - index(local.subnet_objects, sub))
#index(local.subnet_objects, sub) == 0 ? cidrsubnet(local.address, split(":", sub)[1] - local.address_cidr, index(local.subnet_objects, sub)) : cidrsubnet(local.address, split(":", sub)[1] - local.address_cidr, index(local.subnet_objects, sub))
#cidrsubnets(local.address, join(",", local.cidrs))[index(local.subnet_objects, sub)]
#cidrsubnet(local.address, split(":", sub)[1] - local.address_cidr, index(local.subnet_objects, sub))