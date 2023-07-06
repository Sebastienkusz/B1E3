
resource "azurerm_storage_account" "wiki-account" {
  name                     = local.storage_account_name 
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
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

#resource "azurerm_subnet_network_security_group_association" "link-appli" {
#  subnet_id                 = azurerm_subnet.Subnet["sr1"].id
#  network_security_group_id = azurerm_network_security_group.NSG_Appli.id
#}
