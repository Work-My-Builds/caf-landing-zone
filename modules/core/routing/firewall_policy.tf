resource "azurerm_firewall_policy_rule_collection_group" "arcg" {
  for_each = {
    for arcg in local.application_rule_collection_groups : "${arcg.key}|${arcg.subkey}" => arcg
  }

  name               = each.value.application_rule_collection_group_name
  firewall_policy_id = data.azurerm_firewall_policy.afwp[each.value.firewall_policy_name].id
  priority           = each.value.priority

  dynamic "application_rule_collection" {
    for_each = each.value.application_rule_collections
    iterator = arc

    content {
      name     = arc.key
      priority = arc.value.priority
      action   = arc.value.action

      dynamic "rule" {
        for_each = arc.value.rules
        iterator = rule

        content {
          name              = rule.key
          description       = rule.value.description
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            iterator = prot

            content {
              type = prot.value.type
              port = prot.value.port
            }
          }
        }
      }
    }
  }
}


resource "azurerm_firewall_policy_rule_collection_group" "nrcg" {
  for_each = {
    for nrcg in local.network_rule_collection_groups : "${nrcg.key}|${nrcg.subkey}" => nrcg
  }

  name               = each.value.network_rule_collection_group_name
  firewall_policy_id = data.azurerm_firewall_policy.afwp[each.value.firewall_policy_name].id
  priority           = each.value.priority

  dynamic "network_rule_collection" {
    for_each = each.value.network_rule_collections
    iterator = net

    content {
      name     = net.key
      priority = net.value.priority
      action   = net.value.action

      dynamic "rule" {
        for_each = net.value.rules
        iterator = rule

        content {
          name                  = rule.key
          description           = rule.value.description
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports

        }
      }
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "natrcg" {
  for_each = {
    for natrcg in local.nat_rule_collection_groups : "${natrcg.key}|${natrcg.subkey}" => natrcg
  }

  name               = each.value.nat_rule_collection_group_name
  firewall_policy_id = data.azurerm_firewall_policy.afwp[each.value.firewall_policy_name].id
  priority           = each.value.priority

  dynamic "nat_rule_collection" {
    for_each = each.value.nat_rule_collections
    iterator = nat

    content {
      name     = nat.key
      priority = nat.value.priority
      action   = nat.value.action

      dynamic "rule" {
        for_each = nat.value.rules
        iterator = rule

        content {
          name                = rule.key
          description         = rule.value.description
          protocols           = rule.value.protocols
          source_addresses    = rule.value.source_addresses
          destination_address = rule.value.destination_address
          destination_ports   = rule.value.destination_ports
          translated_address  = rule.value.translated_address
          translated_port     = rule.value.translated_port
        }
      }
    }
  }
}