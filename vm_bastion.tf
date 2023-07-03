# NSG Group - Bastion
resource "azurerm_network_security_group" "NSG_Bastion" {
  name                = "${local.resource_group_name}-nsg-${local.bastion_name}"
  location            = local.location
  resource_group_name = local.resource_group_name
}

# NSG Rule - SSH Port - Bastion
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
  network_security_group_name = azurerm_network_security_group.NSG_Bastion.name
}

# Public IP and Label DNS - Bastion
resource "azurerm_public_ip" "Public_IP_Bastion" {
  name                = "${local.resource_group_name}-public_ip-${local.bastion_name}"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = local.public_ip_bastion_allocation
  domain_name_label   = local.public_ip_bastion_dns_name
  ip_version          = local.public_ip_bastion_version
  sku                 = local.public_ip_bastion_sku
  tags                = local.tags
}

# NIC
resource "azurerm_network_interface" "Nic" {
  name                = "${local.resource_group_name}-nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "${local.resource_group_name}-nic-private_ip"
    subnet_id                     = azurerm_subnet.Subnet["sr1"].id
    private_ip_address_allocation = "Dynamic"
  }
}

# VM - Bastion
resource "azurerm_virtual_machine" "VM_Bastion" {
  name                  = "${local.resource_group_name}-vm-${local.bastion_name}"
  location              = local.location
  resource_group_name   = local.resource_group_name
  network_interface_ids = [azurerm_network_interface.Nic.id]
  vm_size               = local.vm_bastion_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${local.resource_group_name}-os_disk-${local.bastion_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "30"
  }
  os_profile {
    computer_name  = local.bastion_name
    admin_username = local.admin
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("~/.ssh/sebastien_rsa.pub")
      path     = "/home/${local.admin}/.ssh/authorized_keys"
    }

  }
  tags = local.tags
}