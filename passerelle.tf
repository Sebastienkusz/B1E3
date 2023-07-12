
###################################################################################################################################################################

resource "azurerm_application_gateway" "main" {
  name                = "${local.resource_group_name}-gateway"
  resource_group_name = local.resource_group_name
  location            = local.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-"
    subnet_id = azurerm_subnet.Subnet["gw"].id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    subnet_id = azurerm_subnet.Subnet["gw"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.Public_IP_Appli.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = "b1e3-gr2-wiki-js.westeurope.cloudapp.azure.com"
    ip_addresses = azurerm_public_ip.Public_IP_Appli.id
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }

  # request_routing_rule {
  #   name                       = local.request_routing_rule_name
  #   rule_type                  = "Basic"
  #   http_listener_name         = local.listener_name
  #   backend_address_pool_name  = local.backend_address_pool_name
  #   backend_http_settings_name = local.http_setting_name
  #   url_path_map_name          = 
  #   priority                   = 1
  # }

  url_path_map {
    name = "challenge"
    path_rule = 
  }
  path_rule {
    name = "acme-challenge"
    paths = ["/.well-known/acme-challenge/*"]
    redirect_configuration_name = azurerm_storage_container.container.name
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-pip"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "nic-ipconfig"
    subnet_id                     = azurerm_subnet.Subnet["sr1"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
  network_interface_id    = azurerm_network_interface.Nic_Appli.id
  ip_configuration_name   = "${local.resource_group_name}-nic-${local.appli_name}-private_ip"
  backend_address_pool_id = tolist(azurerm_application_gateway.main.backend_address_pool).0.id
}

resource "random_password" "password" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}
######################################################################################################################################################

# Configuration de la règle de chemin sur la passerelle d'application
resource "azurerm_application_gateway_url_path_map" "example" {
  name                = "acme-challenge-path-map"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  default_backend_address_pool_name = azurerm_application_gateway_backend_address_pool.example.name
  default_backend_http_settings_name = azurerm_application_gateway_http_setting.example.name

  path_rule {
    name = "acme-challenge-rule"
    paths = ["/.well-known/acme-challenge/*"]

    backend_address_pool_name = azurerm_application_gateway_backend_address_pool.example.name
    backend_http_settings_name = azurerm_application_gateway_http_setting.example.name
  }
}