# Configure the custom landing zones to deploy in
# addition to the core resource hierarchy
locals {
  custom_landing_zones = {
    "${var.root_id}-online" = {
      display_name               = "${upper(var.root_id)} Online"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = var.landing_zone_subscriptions
      archetype_config = {
        archetype_id   = "customer_online"
        parameters     = {}
        access_control = {}
      }
    }
  }
}
