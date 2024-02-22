locals {
  geo_codes      = jsondecode(templatefile("${path.root}/assets/geo-codes.json", {}))
  resource_codes = jsondecode(templatefile("${path.root}/assets/resource-codes.json", {}))

  virtual_network_gateway_name               = lower("${var.prefix}-${local.resource_codes.resources["Virtual network gateway"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  local_network_gateway_name                 = lower("${var.prefix}-${local.resource_codes.resources["Local network gateway"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  firewall_name                              = lower("${var.prefix}-${local.resource_codes.resources["Firewall"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  firewall_policy_name                       = lower("${var.prefix}-${local.resource_codes.resources["Firewall policy"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  vpn_public_ip_address_name                 = lower("${var.prefix}-${local.resource_codes.resources["Public IP address"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-01")
  firewall_public_ip_address_name            = lower("${var.prefix}-${local.resource_codes.resources["Public IP address"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-02")
  firewall_management_public_ip_address_name = lower("${var.prefix}-${local.resource_codes.resources["Public IP address"].abbreviation}-${local.geo_codes.codes[var.location].shortName}-${var.business_code}-${var.environment}-03")

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
    [for dns in toset(local.private_link_dns_zone_by_service) :
      {
        dns                   = dns
        private_dns_zone_name = dns
      }
    ]
  )
}