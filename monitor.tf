# data "azurerm_client_config" "current" {
# }

# resource "azurerm_log_analytics_workspace" "example" {
#   name                = "b1e3-gr2-workspace"
#   location            = local.location
#   resource_group_name = local.resource_group_name
# }

# resource "azurerm_monitor_action_group" "eye" {
#   name                = "b1e3-gr2-monitor_alert"
#   resource_group_name = local.resource_group_name
#   short_name          = "p0action"

#   arm_role_receiver {
#     name                    = "armroleaction"
#     role_id                 = "de139f84-1756-47ae-9be6-808fbbe84772"
#     use_common_alert_schema = true
#   }

# #   automation_runbook_receiver {
# #     name                    = "action_name_1"
# #     automation_account_id   = "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/rg-runbooks/providers/Microsoft.Automation/automationAccounts/aaa001"
# #     runbook_name            = "my runbook"
# #     webhook_resource_id     = "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/rg-runbooks/providers/Microsoft.Automation/automationAccounts/aaa001/webHooks/webhook_alert"
# #     is_global_runbook       = true
# #     service_uri             = "https://s13events.azure-automation.net/webhooks?token=randomtoken"
# #     use_common_alert_schema = true
# #   }

# #   azure_app_push_receiver {
# #     name          = "pushtoadmin"
# #     email_address = "admin@contoso.com"
# #   }

# #   azure_function_receiver {
# #     name                     = "funcaction"
# #     function_app_resource_id = "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/rg-funcapp/providers/Microsoft.Web/sites/funcapp"
# #     function_name            = "myfunc"
# #     http_trigger_url         = "https://example.com/trigger"
# #     use_common_alert_schema  = true
# #   }

#   email_receiver {
#     name          = "sendtoadmin1"
#     email_address = "jlabat@simplonformations.onmicrosoft.com"
#   }

#   email_receiver {
#     name                    = "sendtoadmin2"
#     email_address           = "devops@contoso.com"
#     use_common_alert_schema = true
#   }

#   event_hub_receiver {
#     name                    = "sendtoeventhub"
#     event_hub_namespace     = "eventhubnamespace"
#     event_hub_name          = "eventhub1"
#     subscription_id         = "c56aea2c-50de-4adc-9673-6a8008892c21"
#     use_common_alert_schema = false
#   }

#   itsm_receiver {
#     name                 = "createorupdateticket"
#     workspace_id         = "${data.azurerm_client_config.current.subscription_id}|${azurerm_log_analytics_workspace.example.workspace_id}"
#     connection_id        = "53de6956-42b4-41ba-be3c-b154cdf17b13"
#     ticket_configuration = "{\"PayloadRevision\":0,\"WorkItemType\":\"Incident\",\"UseTemplate\":false,\"WorkItemData\":\"{}\",\"CreateOneWIPerCI\":false}"
#     region               = "southcentralus"
#   }

#   logic_app_receiver {
#     name                    = "logicappaction"
#     resource_id             = "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/rg-logicapp/providers/Microsoft.Logic/workflows/logicapp"
#     callback_url            = "https://logicapptriggerurl/..."
#     use_common_alert_schema = true
#   }

#   sms_receiver {
#     name         = "oncallmsg"
#     country_code = "1"
#     phone_number = "1231231234"
#   }

#   voice_receiver {
#     name         = "remotesupport"
#     country_code = "86"
#     phone_number = "13888888888"
#   }

#   webhook_receiver {
#     name                    = "callmyapiaswell"
#     service_uri             = "http://example.com/alert"
#     use_common_alert_schema = true
#   }
# }