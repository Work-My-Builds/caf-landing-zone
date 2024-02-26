/*module "routing" {
  source = "../../../modules/core/routing"

  routes = jsondecode(file("${path.root}/main.json")).routes
  policies = null
}*/

module "routing" {
  source = "../../../modules/core/routing"

  routes = {
    "cloudgatewayrt" = {
      resource_group_name = "cloudgatewayrg"

      routes_rule = {
        "GatewayRoute-To-Prod-Network" = {
          address_prefix         = "10.109.0.0/16"
          next_hop_type          = "VirtualAppliance" # VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None.
          next_hop_in_ip_address = "10.0.0.1"         # Next hop values are only allowed in routes where the next hop type is VirtualAppliance.
        },
        "GatewayRoute-To-NonProd-Network" = {
          address_prefix         = "10.108.0.0/22"
          next_hop_type          = "VirtualAppliance" # VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None.
          next_hop_in_ip_address = "10.0.0.1"         # Next hop values are only allowed in routes where the next hop type is VirtualAppliance.
        }
      }
    }
  }

  firewall_policies = {
    "cloudgatewayafwp" = {
      resource_group_name = "cloudgatewayrg"

      application_rule_collection_groups = {
        "ApplicationRuleCollectionGroup" = {
          priority = 100
          application_rule_collections = {
            "AccessToWebApplications" = {
              priority = 100
              action   = "Allow"
              rules = {
                "Allow-Access-To-WebApplications" = {
                  description = "Allow access to Microsoft.com from all network on Http and Https"
                  protocols = {
                    "Allow_Http" = {
                      type = "Http"
                      port = 80
                    }
                    "Allow_Https" = {
                      type = "Https"
                      port = 443
                    }
                  }
                  source_addresses  = ["10.109.0.0/16", "10.108.0.0/22"]
                  destination_fqdns = ["*"]
                }
              }
            }
          }
        }
      }

      network_rule_collection_groups = {
        "NetworkRuleCollectionGroup" = {
          priority = 200
          network_rule_collections = {
            "HybridConnection" = {
              priority = 100
              action   = "Allow"
              rules = {
                "Allow-Azure-To-Onprem" = {
                  description           = "Allow Network access to 151.154.0.0/16 from network 10.109.0.0/16 and 10.108.0.0/22 via any protocols"
                  protocols             = ["Any"]
                  source_addresses      = ["10.109.0.0/16", "10.108.0.0/22"]
                  destination_addresses = ["151.154.0.0/16"]
                  destination_ports     = ["*"]
                },
                "Allow-Onprem-To-Azure" = {
                  description           = "Allow Network access to 10.109.0.0/16 and 10.108.0.0/22 from network 151.154.0.0/16 via any protocols"
                  protocols             = ["Any"]
                  source_addresses      = ["151.154.0.0/16"]
                  destination_addresses = ["10.109.0.0/16", "10.108.0.0/22"]
                  destination_ports     = ["*"]
                }
              }
            },
            "AzureToAzureConnection" = {
              priority = 200
              action   = "Allow"
              rules = {
                "Azure_10_109_0_0-To-Azure_10_108_0_0" = {
                  description           = "Allow Network access to 10.109.0.0/16 from network 10.108.0.0/22 via any protocols"
                  protocols             = ["Any"]
                  source_addresses      = ["10.109.0.0/16"]
                  destination_addresses = ["10.108.0.0/22"]
                  destination_ports     = ["*"]
                },
                "Azure_10_108_0_0-To-Azure_10_109_0_0" = {
                  description           = "Allow Network access to 10.108.0.0/22 from network 10.109.0.0/16 via any protocols"
                  protocols             = ["Any"]
                  source_addresses      = ["10.108.0.0/22"]
                  destination_addresses = ["10.109.0.0/16"]
                  destination_ports     = ["*"]
                }
              }
            }
          }
        }
      }

      nat_rule_collection_groups = {
        #"DNATRuleCollectionGroup" = {
        #  priority = 300
        #  nat_rule_collections = {
        #    "nat_rule_collection1" = {
        #      priority = 100
        #      action   = "Dnat"
        #      rules = {
        #        "nat_rule_collection1_rule1" = {
        #          description         = "Allow DNAT access to 192.168.0.1 from network 10.0.0.1 and 10.0.0.2 via TCP and UDP"
        #          protocols           = ["TCP", "UDP"]
        #          source_addresses    = ["10.0.0.1", "10.0.0.2"]
        #          destination_address = "192.168.1.1"
        #          destination_ports   = ["80"]
        #          translated_address  = "192.168.0.1"
        #          translated_port     = "8080"
        #        }
        #      }
        #    }
        #  }
        #}
      }
    }
  }
}

module "production_routing" {
  source = "../../../modules/core/routing"

  providers = {
    azurerm = azurerm.prod
  }
  routes = {
    "cloudprodrt" = {
      resource_group_name = "cloudprodrg"

      routes_rule = {
        "Prod_10_109_0_0-To-Onprem" = {
          address_prefix         = "151.154.0.0/16"
          next_hop_type          = "VirtualAppliance" # VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None.
          next_hop_in_ip_address = "10.0.0.1"         # Next hop values are only allowed in routes where the next hop type is VirtualAppliance.
        },
        "Prod_10_109_0_0-To-Azure_10_108_0_0" = {
          address_prefix         = "10.108.0.0/22"
          next_hop_type          = "VirtualAppliance" # VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None.
          next_hop_in_ip_address = "10.0.0.1"         # Next hop values are only allowed in routes where the next hop type is VirtualAppliance.
        }
      }
    }
  }
}