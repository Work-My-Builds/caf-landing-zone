terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  subscription_id            = "b07c6415-3b3e-4968-9c83-5f2218fd57fe"
  features {}
}

provider "azurerm" {
  alias                      = "online"
  skip_provider_registration = true
  subscription_id            = "66dfe04d-d0e1-477e-95d7-76af548c04b6"
  features {}
}