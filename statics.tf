data "azurerm_resource_group" "current" {
  name = local.resource_group_name
}

resource "time_static" "main" {}