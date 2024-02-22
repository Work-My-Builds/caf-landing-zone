module "root_policy_definitions" {
  source = "../../modules/policy_definitions"

  providers = {
    azurerm = azurerm.default
  }

  root_scope_resource_id    = "root_scope_resource_id"
  location                  = var.location
  enable_policy_definitions = true
}

module "online" {
  source = "../../modules/landing"

  providers = {
    azurerm = azurerm.hub
  }

  location                      = var.location
  prefix                        = var.prefix
  business_code                 = "abc"
  environment                   = "Production"
  root_scope_resource_id        = "root_scope_resource_id"
  management_group_id           = "livemg"
  subscription_id               = "subscription_id"
  enable_policy_assignments     = true                   #Set to true if default policy assignment is required on the subscription.
  exclude_policy_assignments    = []                     #Add all the policy you wish to exclude
  enable_monitoring             = true                   #Set to true if this is a monitoring is needed.
  enable_backup                 = true                   #Set to true if this is a back is needed.
  enable_network                = true                   #Set to true if this is virtual network is needed.
  enable_hub_network            = false                  #Set to true if this is a hub network.
  vulnerabilityAssessmentsEmail = "micheal.falowo@email" #Set only if monitoring is enabled above. comment out if not.
  emailSecurityContact          = "micheal.falowo@email" #Set only if monitoring is enabled above. comment out if not.
  role_assignments = {
    #group_data = {
    #  "AZ_Subscription_Owner" = "Subscription-Owner"
    #  "AZ_Application_Owners" = "Application-Owners"
    #}

    user_data = {
      "micheal.falowo@email" = "Owner"
      "micheal.falowo@email" = "Contributor"
    }

    # See list of available Role definitions to assign to users or group
    #"Application-Owners",
    #"Network-Management",
    #"Network-Subnet-Contributor",
    #"Security-Operations"
    #"Subscription-Owner"
  }

  virtual_network = {
    subnets = [
      "compute:24",
      "pe:24",
      "data:28",
      "web:28"
    ]

    peered_vnet_id = [
      #"spoke:
    ]
    network_address_space   = ["10.0.0.0/16"]
    network_dns_address     = []                #Set if this is a spoke network needs a custom dns server.
    onpremise_gateway_ip    = "100.100.100.100" #Set only if this is a hub network.
    onpremise_address_space = null              #Set only if this is a hub network and BGP is peering settings below is not set.
    onpremise_bgp_peering_settings = [{         #Set only if this is a hub network and connection require BGP. if not set as empty list [].
      asn                 = 20120
      bgp_peering_address = "10.0.0.20"
    }]
  }

  depends_on = [
    module.root_policy_definitions
  ]
}