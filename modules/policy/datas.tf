data "azurerm_subscription" "subscription" {
  subscription_id = split("/", var.subscription_id)[2]
}