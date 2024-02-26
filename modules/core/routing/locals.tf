locals {
  route_tables = flatten(
    [for key, val in try(var.routes, {}) :
      {
        key                 = key
        route_table_name    = key
        resource_group_name = val.resource_group_name
      }

    ]
  )

  routes = flatten(
    [for key, val in try(var.routes, {}) :
      [for subkey, subval in val.routes_rule :
        {
          key                    = key
          subkey                 = subkey
          route_table_name       = key
          route_name             = subkey
          address_prefix         = subval.address_prefix
          next_hop_type          = subval.next_hop_type
          next_hop_in_ip_address = lower(subval.next_hop_type) != "virtualappliance" ? null : subval.next_hop_in_ip_address
        }
      ]
    ]
  )

  firewall_policy = flatten(
    [for key, val in try(var.firewall_policies, {}) :
      {
        key                  = key
        firewall_policy_name = key
        resource_group_name  = val.resource_group_name
      }
    ]
  )

  application_rule_collection_groups = flatten(
    [for key, val in try(var.firewall_policies, {}) :
      [for subkey, subval in val.application_rule_collection_groups :
        {
          key                                    = key
          subkey                                 = subkey
          firewall_policy_name                   = key
          application_rule_collection_group_name = subkey
          priority                               = subval.priority
          application_rule_collections           = subval.application_rule_collections
        }
      ]
    ]
  )

  network_rule_collection_groups = flatten(
    [for key, val in try(var.firewall_policies, {}) :
      [for subkey, subval in val.network_rule_collection_groups :
        {
          key                                = key
          subkey                             = subkey
          firewall_policy_name               = key
          network_rule_collection_group_name = subkey
          priority                           = subval.priority
          network_rule_collections           = subval.network_rule_collections
        }
      ]
    ]
  )

  nat_rule_collection_groups = flatten(
    [for key, val in try(var.firewall_policies, {}) :
      [for subkey, subval in val.nat_rule_collection_groups :
        {
          key                            = key
          subkey                         = subkey
          firewall_policy_name           = key
          nat_rule_collection_group_name = subkey
          priority                       = subval.priority
          nat_rule_collections           = subval.nat_rule_collections
        }
      ]
    ]
  )
}