data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "coffre" {
  name                        = "b1e3gr2keyvault"
  location                    = local.location
  resource_group_name         = local.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_storage_account" "key_storage" {
  name                     = "b1e3gr2keyvaultstorage"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "container"
  storage_account_name  = azurerm_storage_account.key_storage.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "testsb" {
  name                   = "/.well-known/acme-challenge/*"
  storage_account_name   = azurerm_storage_account.key_storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Append"
}