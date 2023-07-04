locals {
  subscription_id     = "c56aea2c-50de-4adc-9673-6a8008892c21"
  admin               = "azureuser"
  resource_group_name = "b1e3-gr2"
  location            = data.azurerm_resource_group.current.location
}

locals {
  network_base = "10.1.0.0/16"
  network_name = "vn"
  subnets = {
    "sr1"     = "10.1.0.0/24"
    "sr2"     = "10.1.1.0/24"
    "gateway" = "10.1.2.0/24"
  }
}

# VM Bastion
locals {
  bastion_name                 = "bastion"
  nsg_bastion_rule_ipfilter    = "82.126.234.200" # IP Box 
  nsg_bastion_rule_sshport     = "22"
  public_ip_bastion_version    = "IPv4"
  public_ip_bastion_dns_name   = "${local.resource_group_name}-${local.bastion_name}"
  public_ip_bastion_sku        = "Standard" # Basic or Standard
  public_ip_bastion_allocation = "Static"   # Static or Dynamic
  vm_bastion_size              = "Standard_B2s"
}

# VM Appli
locals {
  appli_name                 = "wiki-js"
  public_ip_appli_version    = "IPv4"
  public_ip_appli_dns_name   = "${local.resource_group_name}-${local.appli_name}"
  public_ip_appli_sku        = "Standard" # Basic or Standard
  public_ip_appli_allocation = "Static"   # Static or Dynamic
  vm_appli_size              = "Standard_D2s_v3"
}


locals {
  tags = {
    Development = basename(abspath(path.root))
    Owner       = local.admin
    DeployID    = formatdate("YYYY-MM-DD", time_static.main.rfc3339)
    Environment = "Preproduction"
  }
}