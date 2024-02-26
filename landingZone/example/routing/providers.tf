provider "azurerm" {
  skip_provider_registration = true
  subscription_id            = "66dfe04d-d0e1-477e-95d7-76af548c04b6"
  features {}
}

provider "azurerm" {
  alias                      = "prod"
  skip_provider_registration = true
  subscription_id            = "a83ba213-45fa-4153-bd33-56a51d640d35"
  features {}
}