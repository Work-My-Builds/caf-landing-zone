provider "azurerm" {
  subscription_id = var.subscription_id_identity
  features {}
}

# Declare an aliased provider block using your preferred configuration.
# This will be used for the deployment of all "Connectivity resources" to the specified `subscription_id`.

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.subscription_id_connectivity
  features {}
}

# Declare a standard provider block using your preferred configuration.
# This will be used for the deployment of all "Management resources" to the specified `subscription_id`.

provider "azurerm" {
  alias           = "management"
  subscription_id = var.subscription_id_management
  features {}
}