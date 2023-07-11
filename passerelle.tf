

# resource "azurerm_public_ip" "example" {
#   name                = "example-pip"
#   resource_group_name = local.resource_group_name
#   location            = local.location
#   allocation_method   = "Dynamic"
# }

# # since these variables are re-used - a locals block makes this more maintainable
# locals {
#   backend_address_pool_name      = "${azurerm_subnet.Subnet.name}-beap"
#   frontend_port_name             = "${azurerm_subnet.Subnet.name}-feport"
#   frontend_ip_configuration_name = "${azurerm_subnet.Subnet.name}-feip"
#   http_setting_name              = "${azurerm_virtual_network.Vnet.name}-be-htst"
#   listener_name                  = "${azurerm_virtual_network.Vnet.name}-httplstn"
#   request_routing_rule_name      = "${azurerm_virtual_network.Vnet.name}-rqrt"
#   redirect_configuration_name    = "${azurerm_virtual_network.Vnet.name}-rdrcfg"
# }

# resource "azurerm_application_gateway" "network" {
#   name                = "appgateway"
#   resource_group_name = local.resource_group_name
#   location            = local.location

#   sku {
#     name     = "Standard_Small"
#     tier     = "Standard"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "my-gateway-ip-configuration"
#     subnet_id = azurerm_subnet.Subnet["sr1"].id
#     public_ip_address_id = azurerm_public_ip.Public_IP_Appli.id
#   }

#   frontend_port {
#     name = local.frontend_port_name
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                 = local.frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.Public_IP_Appli.id
#   }

#   backend_address_pool {
#     name = local.backend_address_pool_name
#   }

#   backend_http_settings {
#     name                  = local.http_setting_name
#     cookie_based_affinity = "Disabled"
#     path                  = "/path1/"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 60
#   }

#   http_listener {
#     name                           = local.listener_name
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = local.request_routing_rule_name
#     rule_type                  = "Basic"
#     http_listener_name         = local.listener_name
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name
#   }
# }


# resource "azurerm_public_ip" "public_ip" {
#   name                = "application_gateway_IP"
#   resource_group_name = local.resource_group_name
#   location            = local.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

###################################################################################################################################################################

resource "azurerm_application_gateway" "main" {
  name                = "AppGateway"
  resource_group_name = local.resource_group_name
  location            = local.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.Subnet["gateway"].id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.Public_IP_Appli.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 1
  }
}

resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "nic-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-ipconfig-${count.index+1}"
    subnet_id                     = azurerm_subnet.Subnet["sr1"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "nic-ipconfig-${count.index+1}"
  backend_address_pool_id = one(azurerm_application_gateway.main.backend_address_pool).id
}

resource "random_password" "password" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}
######################################################################################################################################################
# resource "azurerm_windows_virtual_machine" "vm" {
#   count               = 2
#   name                = "myVM${count.index+1}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   size                = "Standard_DS1_v2"
#   admin_username      = "azureadmin"
#   admin_password      = random_password.password.result

#   network_interface_ids = [
#     azurerm_network_interface.nic[count.index].id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }


#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }
# }

# resource "azurerm_virtual_machine_extension" "vm-extensions" {
#   count                = 2
#   name                 = "vm${count.index+1}-ext"
#   virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"

#   settings = <<SETTINGS
#     {
#         "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
#     }
# SETTINGS

# }