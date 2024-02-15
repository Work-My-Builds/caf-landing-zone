module "root" {
  source = "../../modules/policy"

  location            = var.location
  prefix              = var.prefix
  business_code       = "onl"
  management_group_id = "/providers/Microsoft.Management/managementGroups/testmg"
  subscription_id     = "/subscriptions/subscription_id"
  #users                             = var.users
  enable_role_definitions   = true
  enable_policy_definitions = true
  #enable_policy_assignments         = true
  #BudgetContactEmails               = var.BudgetContactEmails
  #BudgetAmount                      = var.BudgetAmount
  #vulnerabilityAssessmentsEmail     = var.vulnerabilityAssessmentsEmail
  #logAnalyticWorkspaceID            = var.logAnalyticWorkspaceID
  #emailSecurityContact              = var.emailSecurityContact
  #ascExportResourceGroupName        = var.ascExportResourceGroupName
  #vulnerabilityAssessmentsStorageID = var.vulnerabilityAssessmentsStorageID
  #enable_network                    = var.enable_network
  #enable_monitoring                 = var.enable_monitoring
  #virtual_network                   = var.virtual_network
}

module "online" {
  source = "../../modules/policy"

  location            = var.location
  prefix              = var.prefix
  business_code       = "onl"
  management_group_id = "/providers/Microsoft.Management/managementGroups/testmg"
  subscription_id     = "/subscriptions/subscription_id"
  #users                             = var.users
  #enable_role_definitions           = true
  #enable_policy_definitions         = true
  enable_policy_assignments = true
  #BudgetContactEmails               = var.BudgetContactEmails
  #BudgetAmount                      = var.BudgetAmount
  #vulnerabilityAssessmentsEmail     = var.vulnerabilityAssessmentsEmail
  #logAnalyticWorkspaceID            = var.logAnalyticWorkspaceID
  #emailSecurityContact              = var.emailSecurityContact
  #ascExportResourceGroupName        = var.ascExportResourceGroupName
  #vulnerabilityAssessmentsStorageID = var.vulnerabilityAssessmentsStorageID
  enable_network    = true
  enable_monitoring = true
  virtual_network = {
    enable_hub_network = true
    subnets = [
      "compute:24",
      "pe:28",
      "data:24",
      "web:28"
    ]
    //peered_vnet_id                 = null
    network_address_space   = ["10.0.0.0/16"]
    network_dns_address     = []
    ddos_protection_plan_id = "ddos_id"
    onpremise_gateway_ip    = "100.100.100.100"
    onpremise_address_space = []
    onpremise_bgp_peering_settings = [{
      asn                 = 20120
      bgp_peering_address = "10.0.0.20"
    }]
  }

  providers = {
    azurerm = azurerm.online
  }
}