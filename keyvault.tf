data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "coffre_fort" {
  name                        = local.key_vault_name
  location                    = local.location
  resource_group_name         = local.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "ssl" {
  for_each     = data.azuread_user.admin
  key_vault_id = azurerm_key_vault.coffre_fort.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.object_id

  key_permissions         = ["Get", "List", "Encrypt", "Decrypt"]
  certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
  secret_permissions      = ["Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions     = []
}

resource "azurerm_key_vault_access_policy" "tls" {
  key_vault_id = azurerm_key_vault.coffre_fort.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.bonne.principal_id

  key_permissions         = []
  certificate_permissions = []
  secret_permissions      = ["Get"]
  storage_permissions     = []
}

resource "azurerm_storage_account" "key_storage" {
  name                     = local.key_vault_storage
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "acme"
  storage_account_name  = azurerm_storage_account.key_storage.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "testsb" {
  name                   = "/.well-known/acme-challenge/*"
  storage_account_name   = azurerm_storage_account.key_storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Append"
}

data "azurerm_key_vault_certificate" "app" {
  name         = local.appli_name
  key_vault_id = azurerm_key_vault.coffre_fort.id
  depends_on   = [null_resource.ssl_cert]
}