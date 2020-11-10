data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

provider "azurerm" {
  features {}
  
  version = "=2.31.1"
  
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}



resource "azurerm_resource_group" "machine-learning-resource-group" {
  name     = "rg-data-science-${var.azure_sub_name}"
  location = "uksouth"
}

resource "azurerm_storage_account" "machine-learning-storage-account" {
  name                     = "stml${var.azure_sub_name}"
  resource_group_name      = azurerm_resource_group.machine-learning-resource-group.name
  location                 = azurerm_resource_group.machine-learning-resource-group.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "GRS"

  tags = {
    owner       = "data-science"
    environment = "${var.azure_sub_name}"
    project     = "machine-learning"
  }
}

resource "azurerm_storage_container" "machine-learning-storage-container" {
  name                  = "stcontml${var.azure_sub_name}"
  storage_account_name  = azurerm_storage_account.machine-learning-storage-account.name
  container_access_type = "private"
}

resource "azurerm_application_insights" "machine-learning-insights" {
  name                = "appi-ml-${var.azure_sub_name}"
  location            = azurerm_resource_group.machine-learning-resource-group.location
  resource_group_name = azurerm_resource_group.machine-learning-resource-group.name
  application_type    = "other"
}


# have to use ARM for the machine learning environment

resource "azurerm_container_registry" "machine-learning-container-registry" {
  name                = "acrml${var.azure_sub_name}"
  resource_group_name = azurerm_resource_group.machine-learning-resource-group.name
  location            = azurerm_resource_group.machine-learning-resource-group.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_key_vault" "machine-learning-keyvault" {
  name                = "kv-ml-${var.azure_sub_name}"
  location            = azurerm_resource_group.machine-learning-resource-group.location
  resource_group_name = azurerm_resource_group.machine-learning-resource-group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"
}

resource "azurerm_machine_learning_workspace" "machine-learning-workspace" {
  name                = "mlw-ml-${var.azure_sub_name}"
  resource_group_name = azurerm_resource_group.machine-learning-resource-group.name
  depends_on = [
    azurerm_storage_account.machine-learning-storage-account,
    azurerm_application_insights.machine-learning-insights,
    azurerm_key_vault.machine-learning-keyvault,
    azurerm_container_registry.machine-learning-container-registry
  ]
  key_vault_id              = azurerm_key_vault.machine-learning-keyvault.id
  application_insights_id   = azurerm_application_insights.machine-learning-insights.id
  storage_account_id        = azurerm_storage_account.machine-learning-storage-account.id
  container_registry_id     = azurerm_container_registry.machine-learning-container-registry.id
  location                  =  azurerm_resource_group.machine-learning-resource-group.location
    identity {
    type = "SystemAssigned"
  }
  }
