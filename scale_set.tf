
# resource "azurerm_linux_virtual_machine_scale_set" "scale" {
#   name                = "appli-scale-set"
#   location            = local.location
#   resource_group_name = local.resource_group_name
#   upgrade_mode        = "Manual"
#   sku                 = "Standard_F2"
#   instances           = 8
#   admin_username      = local.admin


#  admin_ssh_key {
#     username   = local.admin
#     public_key = tls_private_key.admin_rsa.public_key_openssh
#   }

#   network_interface {
#     name    = "TestNetworkProfile"
#     primary = true

#     ip_configuration {
#       name      = "TestIPConfiguration"
#       primary   = true
#       subnet_id = azurerm_subnet.Subnet["sr1"].id
#     }
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "StandardSSD_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts"
#     version   = "latest"
#   }

#   lifecycle {
#     ignore_changes = ["instances"]
#   }
# }

# resource "azurerm_monitor_autoscale_setting" "example" {
#   name                = "myAutoscaleSetting"
#   resource_group_name = local.resource_group_name
#   location            = local.location
#   target_resource_id  = azurerm_linux_virtual_machine_scale_set.scale.id

#   profile {
#     name = "defaultProfile"

#     capacity {
#       default = 2
#       minimum = 2
#       maximum = 8
#     }

#     rule {
#       metric_trigger {
#         metric_name        = "Virtual Machine Scale Sets"
#         metric_resource_id = azurerm_linux_virtual_machine_scale_set.scale.id
#         time_grain         = "PT1M"
#         statistic          = "Average"
#         time_window        = "PT5M"
#         time_aggregation   = "Average"
#         operator           = "GreaterThan"
#         threshold          = 90
#         metric_namespace   = "microsoft.compute/virtualmachinescalesets"
#         dimensions {
#           name     = "AppName"
#           operator = "Equals"
#           values   = ["App1"]
#         }
#       }

#       scale_action {
#         direction = "Increase"
#         type      = "ChangeCount"
#         value     = "8"
#         cooldown  = "PT1M"
#       }
#     }


    
#     }
#   }

#   predictive {
#     scale_mode      = "Enabled"
#     #look_ahead_time = "PT5M"
#   }

#   notification {
#     email {
#       send_to_subscription_administrator    = true
#       send_to_subscription_co_administrator = true
#       custom_emails                         = ["jlabat@simplonformations.onmicrosoft.com"]
#     }
#   }
# }