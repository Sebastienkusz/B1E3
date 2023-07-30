# Data to declare the location of the resource group
data "azurerm_resource_group" "current" {
  name = local.resource_group_name
}

# Resource to fix time for the tfstate
resource "time_static" "main" {}

# Data source to get admin users' object_id and use it in the key vault access policy
data "azuread_user" "admin" {
  for_each            = local.users
  user_principal_name = each.value.email
}