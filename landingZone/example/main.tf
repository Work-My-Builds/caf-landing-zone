module "root_policy_definitions" {
  source = "../../../Terraform_Modules/root_management_policies"

  providers = {
    azurerm = azurerm.root
  }

  root_scope_resource_id = "mg-<business name>"
  child_management_groups = [
    "Platform",
    "Workload"
  ]
  location                  = var.location
  enable_policy_definitions = true
  enable_policy_assignments = true
}

module "platform" {
  source = "../../Terraform_Modules/landing" #

  providers = {
    azurerm = azurerm.root
  }

  location                             = var.location
  environment                          = "Shared"
  root_scope_resource_id               = "root_scope_resource_id"
  management_group_id                  = "management_group_id"
  subscription_id                      = "subscription_id"
  exclude_policy_assignments           = [] #Add all the policy you wish to exclude
  enable_monitoring_policy_assignments = true
  enable_backup_policy_assignments     = true
  enable_monitoring                    = true                           #Set to true if this is a monitoring is needed.
  enable_backup                        = true                           #Set to true if this is a back is needed.
  enable_network                       = true                           #Set to true if this is virtual network is needed.
  enable_hub_network                   = true                           #Set to true if this is a hub network.
  vulnerabilityAssessmentsEmail        = "micheal.falowo@email" #Set only if monitoring is enabled above. comment out if not.
  emailSecurityContact                 = "micheal.falowo@email" #Set only if monitoring is enabled above. comment out if not.
  role_assignments = {
    #group_data = {
    #  "AZ_Subscription_Owner" = "Subscription-Owner"
    #  "AZ_Application_Owners" = "Application-Owners"
    #}

    #user_data = {
    #  "micheal.falowo@email" = "Reader"
    #  "micheal.falowo@email" = "Contributor"
    #}

    # See list of available Role definitions to assign to users or group
    #"Application-Owners",
    #"Network-Management",
    #"Network-Subnet-Contributor",
    #"Security-Operations"
    #"Subscription-Owner"
  }

  virtual_network = {
    subnets = []

    peered_vnet_id = [
      #"spoke:
    ]
    network_address_space = ["10.0.0.0/16"]
    network_dns_address   = [] #Set if this is a spoke network needs a custom dns server.
    vpn_client_configuration = {
      address_space = ["10.0.1.0/24"]
      root_certificate = {}
    }
    onpremise_gateway_ip    = "10.0.0.0/16"    #Set only if this is a hub network.
    onpremise_address_space = ["10.0.0.0/16"] #Set only if this is a hub network and BGP is peering settings below is not set.
  }
}

module "prod-workload" {
  source = "../../Terraform_Modules/landing" #

  providers = {
    azurerm = azurerm.prod
  }

  location                             = var.location
  environment                          = "environment"
  root_scope_resource_id               = "root_scope_resource_id"
  management_group_id                  = "management_group_id"
  subscription_id                      = "subscription_id"
  exclude_policy_assignments           = [] #Add all the policy you wish to exclude
  enable_monitoring_policy_assignments = true
  enable_backup_policy_assignments     = true
  mon_resource_group_name              = "mon_resource_group_name"
  mon_log_analytics_workspace_id       = "mon_log_analytics_workspace_id"
  mon_storage_account_id               = "mon_storage_account_id"
  mon_identity_id                      = "mon_identity_id"
  backup_policy_id                     = "backup_policy_id"
  backup_identity_id                   = "backup_identity_id"
  backup_storage_account_id            = "backup_storage_account_id"
  enable_network                       = true                           #Set to true if this is virtual network is needed.
  enable_hub_network                   = false                          #Set to true if this is a hub network.
  vulnerabilityAssessmentsEmail        = "micheal.falowo@email" #Set only if monitoring is enabled above. comment out if not.
  emailSecurityContact                 = "micheal.falowo@email" #Set only if monitoring is enabled above. comment out if not.
  role_assignments = {
    #group_data = {
    #  "AZ_Subscription_Owner" = "Subscription-Owner"
    #  "AZ_Application_Owners" = "Application-Owners"
    #}

    #user_data = {
    #  "micheal.falowo@email" = "Reader"
    #  "micheal.falowo@email" = "Contributor"
    #}

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
      "hub:"
    ]
    network_address_space = ["10.10.0.0/16"]
    vpn_client_configuration = {
      address_space        = []
      vpn_client_protocols = []
      vpn_auth_types       = []
      root_certificate     = {}
    }
  }
}