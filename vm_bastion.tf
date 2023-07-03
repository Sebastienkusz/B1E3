# NSG Group
resource "azurerm_network_security_group" "NSG_Bastion" {
  name                = "${local.resource_group_name}-${local.nsg-bastion}"
  location            = local.location
  resource_group_name = local.resource_group_name
}


resource "azurerm_network_security_rule" "NSG_Bastion_Rules" {
  name                        = "SSH_Rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = local.nsg_bastion_rule_sshport
  source_address_prefix       = local.nsg_bastion_rule_ipfilter
  destination_address_prefix  = "*"
  resource_group_name         = local.resource_group_name
  network_security_group_name = "${local.resource_group_name}-${local.nsg-bastion}"
}