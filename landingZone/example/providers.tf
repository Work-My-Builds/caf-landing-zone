terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }
}

provider "azurerm" {
  #alias                      = "identity"
  skip_provider_registration = true
  subscription_id            = "sub id"
  features {}
}