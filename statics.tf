# Data to declare the location of the resource group
data "azurerm_resource_group" "current" {
  name = local.resource_group_name
}

# Resource to fix time for the tfstate
resource "time_static" "main" {}