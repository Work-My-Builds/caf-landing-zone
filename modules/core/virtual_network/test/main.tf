provider "azurerm" {
  skip_provider_registration = true
  features {

  }
}



locals {
  address      = "10.0.0.0/16"
  address_cidr = split("/", local.address)[1]

  subnet_objects = [
    "abc:24",
    "def:24",
    "ghi:28",
    "jkl:28"
  ]
  
  cidrs = [
    for cidr in local.subnet_objects : tonumber(split(":", cidr)[1] - split("/", local.address)[1])
  ]

  subnets = flatten(
    [for sub in toset(local.subnet_objects) : {
      name     = lower(split(":", sub)[0])
      new_bits = cidrsubnets(local.address, local.cidrs[*]...)[index(local.subnet_objects, sub)]
      }
    ]
  )

  #cidrsubnets(var.base_cidr_block, var.networks[*].new_bits...)
}

output "subnet_address_range" {
  value = local.subnets
}