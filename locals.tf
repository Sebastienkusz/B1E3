locals {
  subscription_id     = "c56aea2c-50de-4adc-9673-6a8008892c21"
  user                = "azureuser"
  resource_group_name = "b1e3-gr2"
  location            = data.azurerm_resource_group.current.location
}

locals {
  network_base = "10.1.0.0/16"
  network_name = "vn"
  subnets = {
    "sr1" = "10.1.0.0/24"
    "sr2"     = "10.1.1.0/24"
    "gateway"      = "10.1.2.0/24"
  }
}

locals {
  tags = {
    TP       = basename(abspath(path.root))
    Owner    = local.user
    DeployID = formatdate("YYYY-MM-DD", time_static.main.rfc3339)
  }
}