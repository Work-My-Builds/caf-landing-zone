data "azurerm_virtual_network" "vnet" {
  name                = split("/", var.vnet_id)[8]
  resource_group_name = split("/", var.vnet_id)[4]
}