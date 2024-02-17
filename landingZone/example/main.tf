module "root" {
  source = "../../modules/policy"

  location            = var.location
  prefix              = var.prefix
  business_code       = "onl"
  management_group_id = "/providers/Microsoft.Management/managementGroups/testmg"
  subscription_id     = "/subscriptions/subscription_id"
  #users                             = var.users
  enable_role_definitions   = true #Set to true if default role definition is required on the management group.
  enable_policy_definitions = true #Set to true if default policy definition is required on the management group.
}

module "online" {
  source = "../../modules/policy"

  location            = var.location
  prefix              = var.prefix
  business_code       = "onl"
  management_group_id = "/providers/Microsoft.Management/managementGroups/testmg"
  subscription_id     = "/subscriptions/subscription_id"
  user_data = {
    "user email1" = "Owner"
    "user email2" = "Contributor"
  }
  #enable_role_definitions           = true #Set to true if default role definition is required on the management group.
  #enable_policy_definitions         = true #Set to true if default policy definition is required on the management group.
  enable_policy_assignments = true #Set to true if default policy assignment is required on the subscription.
  exclude_policy_assignments = [   #Add all the policy you wish to exclude
  ]

  enable_monitoring = true #Set to true if this is a monitoring is needed.
  enable_backup     = true #Set to true if this is a back is needed.

  vulnerabilityAssessmentsEmail = "user email" #Set only if monitoring is enabled above. comment out if not.
  emailSecurityContact          = "user email" #Set only if monitoring is enabled above. comment out if not.



  enable_network     = true #Set to true if this is virtual network is needed.
  enable_hub_network = true #Set to true if this is a hub network.
  virtual_network = {
    subnets = [
      "compute:24",
      "pe:24",
      "data:28",
      "web:28"
    ]
    //peered_vnet_id                 = null
    network_address_space   = ["10.0.0.0/16"]
    network_dns_address     = []                        #Set if this is a spoke network needs a custom dns server.
    ddos_protection_plan_id = "ddos_protection_plan_id" #Set is ddos is need and this is a  spoke network.
    onpremise_gateway_ip    = "100.100.100.100"         #Set only if this is a hub network.
    onpremise_address_space = []                        #Set only if this is a hub network and BGP is peering settings below is not set.
    onpremise_bgp_peering_settings = [{                 #Set only if this is a hub network and connection require BGP. if not set as empty list [].
      asn                 = 20120
      bgp_peering_address = "10.0.0.20"
    }]
  }

  providers = {
    azurerm = azurerm.online
  }
}