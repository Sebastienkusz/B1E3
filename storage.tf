
resource "azurerm_storage_account" "wiki-account" {
  name                     = local.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "share" {
  name                 = "${local.resource_group_name}-${local.share_name}"
  storage_account_name = azurerm_storage_account.wiki-account.name
  quota                = 5
}

resource "azurerm_storage_share_directory" "smb" {
  name                 = "${local.resource_group_name}-${local.share_directory_name}"
  share_name           = azurerm_storage_share.share.name
  storage_account_name = azurerm_storage_account.wiki-account.name
}

# Create variables file for ansible
resource "local_file" "storage_main_yml" {
  filename        = "${path.module}/ansible/roles/storage/defaults/main.yml"
  file_permission = "0644"
  content         = <<-EOT
# Variables to mount storage disk
storage_account_name: "${local.resource_group_name}-${local.share_name}"
share_name: "${local.storage_account_name}"
EOT
}