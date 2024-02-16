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
  subnet_cidrs = [
    for cidr in var.subnets : tonumber(split(":", cidr)[1] - local.address_cidr)
  ]

  subnets = flatten(
    [for sub in toset(var.subnets) : {
      name     = lower(split(":", sub)[0]) == "AzureFirewallSubnet" || lower(split(":", sub)[0]) == "AzureFirewallManagementSubnet" || lower(split(":", sub)[0]) == "AzureBastionSubnet" || lower(split(":", sub)[0]) == "GatewaySubnet" ? lower(split(":", sub)[0]) : lower("${local.subnet_prefix}-${lower(split(":", sub)[0])}")
      address_prefixes = cidrsubnets(var.network_address_space[0], local.subnet_cidrs[*]...)[index(var.subnets, sub)]
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

  private_link_dns_zone_by_service = [
    "privatelink.azure-api.net", 
    "privatelink.developer.azure-api.net",
    "privatelink.azconfig.io",
    "privatelink.his.arc.azure.com",
    "privatelink.guestconfiguration.azure.com",
    "privatelink.kubernetesconfiguration.azure.com",
    "privatelink.azure-automation.net",
    "privatelink.batch.azure.com",
    "privatelink.directline.botframework.com",
    "privatelink.token.botframework.com",
    "privatelink.redis.cache.windows.net",
    "privatelink.redisenterprise.cache.azure.net",
    "privatelink.azurecr.io",
    "privatelink.cassandra.cosmos.azure.com",
    "privatelink.gremlin.cosmos.azure.com",
    "privatelink.mongo.cosmos.azure.com",
    "privatelink.documents.azure.com",
    "privatelink.table.cosmos.azure.com",
    "privatelink.datafactory.azure.net",
    "privatelink.adf.azure.com",
    "privatelink.azurehealthcareapis.com",
    "privatelink.dicom.azurehealthcareapis.com",
    "privatelink.dfs.core.windows.net",
    "privatelink.mariadb.database.azure.com",
    "privatelink.mysql.database.azure.com",
    "privatelink.postgres.database.azure.com",
    "privatelink.digitaltwins.azure.net",
    "privatelink.eventgrid.azure.net",
    "privatelink.servicebus.windows.net",
    "privatelink.afs.azure.net",
    "privatelink.azurehdinsight.net",
    "privatelink.azure-devices-provisioning.net",
    "privatelink.azure-devices.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.managedhsm.azure.net",
    "privatelink.api.azureml.ms",
    "privatelink.notebooks.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.media.azure.net",
    "privatelink.prod.migration.windowsazure.com",
    "privatelink.monitor.azure.com",
    "privatelink.oms.opinsights.azure.com",
    "privatelink.ods.opinsights.azure.com",
    "privatelink.agentsvc.azure-automation.net",
    "privatelink.purview.azure.com",
    "privatelink.purviewstudio.azure.com",
    "privatelink.search.windows.net",
    "privatelink.siterecovery.windowsazure.com",
    "privatelink.database.windows.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.azuresynapse.net",
    "privatelink.azurewebsites.net",
    "privatelink.azurestaticapps.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.analysis.windows.net",
    "privatelink.pbidedicated.windows.net",
    "privatelink.tip1.powerquery.microsoft.com",
    "privatelink.service.signalr.net",
    "privatelink.webpubsub.azure.com",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.web.core.windows.net",
    "privatelink.${local.geo_codes.codes[var.location].shortName}.backup.windowsazure.com",
    "privatelink.${var.location}.kusto.windows.net",
    "privatelink.${var.location}.azmk8s.io"
  ]

  private_dns_zones = flatten(
    [ for dns in toset(local.private_link_dns_zone_by_service):
      {
        dns = dns
        private_dns_zone_name = dns
      } if var.enable_hub_network == true
    ]
  )
}