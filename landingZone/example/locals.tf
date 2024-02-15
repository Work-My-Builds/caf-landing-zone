locals {
  subscription1 = {
    environment           = "Development"
    management_group_name = "testmg"
    subcription_name      = "Online-Sub"
    subscription_id       = "66dfe04d-d0e1-477e-95d7-76af548c04b6"
    users = {
      "Owner"       = "mazie@mytecloud.com"
      "Contributor" = "martin@mytecloud.com"
    }
    enable_network        = true
    network_address_space = ["10.0.0.0/16"]

  }

  #subscription_object = flatten([
  #  for sub, data in local.subscriptions : {
  #    sub                   = sub
  #    subscription_name     = sub
  #    environment           = data.environment
  #    management_group_name = data.management_group_name
  #    subscription_id       = data.subscription_id
  #    users                 = data.users
  #  }
  #])
}