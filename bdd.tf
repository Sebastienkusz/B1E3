

resource "azurerm_mariadb_server" "serverdb" {
  name                          = "${local.resource_group_name}-${local.server_name}"
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku_name                      = "B_Gen5_2"
  storage_mb                    = 5120
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  administrator_login           = local.admin
  administrator_login_password  = "P@$$w0rd"
  version                       = "10.3"
  ssl_enforcement_enabled       = true
  #public_network_access_enabled = false
}

resource "azurerm_mariadb_database" "database" {
  name                = local.database_name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mariadb_server.serverdb.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_520_ci"
}

# resource "azurerm_mariadb_virtual_network_rule" "example" {
#   name                = "mariadb-vnet-rule"
#   resource_group_name = local.resource_group_name
#   server_name         = azurerm_mariadb_server.serverdb.name
#   subnet_id           = azurerm_subnet.Subnet["sr2"].id
# }

resource "azurerm_network_security_group" "nsg_mariadb" {
  name                = "${local.resource_group_name}-nsg-${local.nsg_name}"
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_network_security_rule" "mariadb_rule" {
  name                        = "${local.resource_group_name}-${local.nsg_rule_name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = local.nsg_bdd_rule_mysqlport
  source_address_prefix       = azurerm_linux_virtual_machine.VM_Appli.public_ip_address
  destination_address_prefix  = "*"
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_mariadb.name
}

# resource "azurerm_mariadb_firewall_rule" "firewall" {
#   name                = "firewall-rule"
#   resource_group_name = local.resource_group_name
#   server_name         = "${local.resource_group_name}-${local.server_name}"
#   start_ip_address    = azurerm_network_interface.Nic_Appli.private_ip_address
#   end_ip_address      = azurerm_network_interface.Nic_Appli.private_ip_address
# }

# resource "azurerm_subnet_network_security_group_association" "link" {
# subnet_id                 = azurerm_subnet.Subnet["sr1"].id
#  network_security_group_id = azurerm_network_security_group.nsg_mariadb.id
# }