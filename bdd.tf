resource "azurerm_mariadb_server" "server" {
  name                = "${local.resource_group_name}-server-${local.bdd_name}"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku_name = "B_Gen5_2"
  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  administrator_login          = local.admin
  administrator_login_password = "P@$$w0rd"
  version                      = "10.2"
  ssl_enforcement_enabled      = true
}

resource "azurerm_mariadb_database" "database" {
  name                = "${local.resource_group_name}-database-${local.bdd_name}"
  resource_group_name = local.resource_group_name
  server_name         = "${local.resource_group_name}-server-${local.bdd_name}"
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_520_ci"
}

resource "azurerm_network_security_group" "nsg_mariadb" {
  name                = "${local.resource_group_name}-nsg-${local.bdd_name}"
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_network_security_rule" "mariadb_rule" {
  name                        = local.nsg_name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = local.nsg_bdd_rule_mysqlport
  source_address_prefix       = "Internet"
  destination_address_prefix  = azurerm_mariadb_server.server.fully_qualified_domain_name
  resource_group_name         = local.resource_group_name
  network_security_group_name = "${local.resource_group_name}-nsg-${local.bdd_name}"
}

resource "azurerm_subnet_nsg_association" "link" {
  subnet_id                 = azurerm_subnet.Subnet["sr2"].id
  network_security_group_id = azurerm_network_security_group.mariadb_rule.id
}