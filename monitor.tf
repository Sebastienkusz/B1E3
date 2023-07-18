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

# Creating a Log Analytics workspace 
resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "${local.resource_group_name}-vm-${local.appli_name}-workspace"
  resource_group_name = local.resource_group_name
  location            = local.location
}

# Associating the workspace with the storage account
resource "azurerm_log_analytics_linked_storage_account" "workspace_linked_storage" {
  data_source_type      = "CustomLogs"
  resource_group_name   = local.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_workspace.id
  storage_account_ids   = [azurerm_storage_account.wiki-account.id]
}

# Enabling virtual machine monitoring in Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "vm_wikijs_diagnostic" {
  name                       = "${local.resource_group_name}-vm-${local.appli_name}-diagnostic"
  target_resource_id         = azurerm_linux_virtual_machine.VM_Appli.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Enabling database monitoring in Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "mariadb_diagnostic" {
  name                       = "${local.resource_group_name}-${local.server_name}-diagnostic"
  target_resource_id         = azurerm_mariadb_server.serverdb.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id

  enabled_log {
    category = "MariadbSQLLogs" # "PostgreSQLLogs"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Enable storage space monitoring in Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "storage_diagnostic" {
  name                       = "${local.resource_group_name}-storage-diagnostic"
  target_resource_id         = azurerm_storage_account.wiki-account.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Creation of a workbook containing metrics for the application machine, database and storage account
resource "azurerm_application_insights_workbook" "workbook" {
  name                = "85b3e8bb-fc93-40be-83f2-98f6bec18ba0"
  resource_group_name = local.resource_group_name
  location            = local.location
  display_name        = "${local.resource_group_name}-workbook"
  source_id           = "${local.subscription_id}}"
  data_json = jsonencode({
    "version" : "Notebook/1.0",
    "items" : [
      {
        "type" : 1,
        "content" : {
          "json" : "Metriques de la base de données, de la machine applicative et du compte de stockage."
        },
        "name" : "text - 0"
      },
      {
        "type" : 10,
        "content" : {
          "chartId" : "workbook76a04e93-6e87-4de3-a31b-8e6f79d6ecb5",
          "version" : "MetricsItem/2.0",
          "size" : 0,
          "chartType" : 2,
          "resourceType" : "microsoft.compute/virtualmachines",
          "metricScope" : 0,
          "resourceIds" : [
            "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${local.resource_group_name}-vm-${local.appli_name}"
          ],
          "timeContext" : {
            "durationMs" : 3600000
          },
          "metrics" : [
            {
              "namespace" : "microsoft.compute/virtualmachines",
              "metric" : "microsoft.compute/virtualmachines--Percentage CPU",
              "aggregation" : 4,
              "splitBy" : null,
              "columnName" : "CPU"
            },
            {
              "namespace" : "microsoft.compute/virtualmachines",
              "metric" : "microsoft.compute/virtualmachines--VmAvailabilityMetric",
              "aggregation" : 4,
              "columnName" : "Availability"
            }
          ],
          "gridSettings" : {
            "rowLimit" : 10000
          }
        },
        "name" : "métrique - 1"
      },
      {
        "type" : 10,
        "content" : {
          "chartId" : "workbook3f34abd3-339e-4233-9f28-121dd2631da7",
          "version" : "MetricsItem/2.0",
          "size" : 0,
          "chartType" : 2,
          "resourceType" : "microsoft.dbforpostgresql/servers",
          "metricScope" : 0,
          "resourceIds" : [
            "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.DBforPostgreSQL/servers/${local.db_app_name}-${local.app_name}"
          ],
          "timeContext" : {
            "durationMs" : 1800000
          },
          "metrics" : [
            {
              "namespace" : "microsoft.dbforpostgresql/servers",
              "metric" : "microsoft.dbforpostgresql/servers-Saturation-backup_storage_used",
              "aggregation" : 4,
              "splitBy" : null,
              "columnName" : "Backup storage "
            }
          ],
          "gridSettings" : {
            "rowLimit" : 10000
          }
        },
        "name" : "métrique - 2"
      },
      {
        "type" : 10,
        "content" : {
          "chartId" : "workbook6c43fe94-6262-4c2b-8238-638a0950af10",
          "version" : "MetricsItem/2.0",
          "size" : 0,
          "chartType" : 2,
          "resourceType" : "microsoft.storage/storageaccounts",
          "metricScope" : 0,
          "resourceIds" : [
            "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/b1e3gr0smb"
          ],
          "timeContext" : {
            "durationMs" : 3600000
          },
          "metrics" : [
            {
              "namespace" : "microsoft.storage/storageaccounts",
              "metric" : "microsoft.storage/storageaccounts-Capacity-UsedCapacity",
              "aggregation" : 4,
              "splitBy" : null
            }
          ],
          "gridSettings" : {
            "rowLimit" : 10000
          }
        },
        "name" : "métrique - 3"
      }
    ],
    "fallbackResourceIds" : [
      "${local.subscription_id}"
    ],
    "$schema" : "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })

}

# Creation of an action group to manage alert notifications
resource "azurerm_monitor_action_group" "notification_group" {
  name                = "${local.resource_group_name}-notification-group"
  resource_group_name = local.resource_group_name
  short_name          = "notifgrp"

  email_receiver {
    name          = "emaildom"
    email_address = "dtauzin.ext@simplon.co"
  }
  email_receiver {
    name          = "emailjous"
    email_address = "jpaillusseau.ext@simplon.co"
  }
}

# Create an alert on the remaining storage capacity of the storage account
resource "azurerm_monitor_metric_alert" "metric_alert_storage" {
  name                = "${local.resource_group_name}-storage-metric-alert"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_storage_account.smb.id]
  description         = "Action will be triggered when the storage capacity remaining is below 10%."
  frequency           = "PT1H"
  window_size         = "PT6H"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 4.5 * 1024 * 1024 * 1024 # 4,5 Go
  }

  action {
    action_group_id = azurerm_monitor_action_group.notification_group.id
  }
}

# Creation of an alert on the percentage of CPU usage on the application machine
resource "azurerm_monitor_metric_alert" "metric_alert_cpu" {
  name                = "${local.resource_group_name}-cpu-metric-alert"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.app.id]
  description         = "Alert will be triggered when avg utilization is more than 90%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.notification_group.id
  }
}

# Create an application availability alert
resource "azurerm_monitor_metric_alert" "site_metric_alert_1" {
  name                = "${local.resource_group_name}-web-availablity"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_application_gateway.app.id]
  description         = "Alert triggered when website is unavailable"

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "HealthyHostCount"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.notification_group.id
  }
}

# # Creating an Application Insights resource
# resource "azurerm_application_insights" "app-insights" {
#   name                = "${local.resource_group_name}-app-insights"
#   location            = local.location
#   resource_group_name = local.resource_group_name
#   application_type    = "web"
#   workspace_id        = azurerm_log_analytics_workspace.log_workspace.id
# }

# # Creation of a web probe for the application site
# resource "azurerm_application_insights_standard_web_test" "url_web_test" {
#   name                    = "${local.resource_group_name}-check-website-availability"
#   resource_group_name     = local.resource_group_name
#   location                = "West Europe"
#   application_insights_id = azurerm_application_insights.app-insights.id
#   geo_locations           = ["emea-fr-pra-edge", "emea-gb-db3-azr", "emea-nl-ams-azr", "emea-se-sto-edge", "emea-ru-msa-edge"]
#   enabled                 = true
#   retry_enabled           = true

#   request {
#     url       = "https://${local.resource_group_name}-nextcloud.westeurope.cloudapp.azure.com/"
#     http_verb = "GET"
#   }
#   validation_rules {
#     ssl_cert_remaining_lifetime = "7"
#     ssl_check_enabled           = true
#     expected_status_code        = 200
#   }
# }

# # Create an application availability alert
# resource "azurerm_monitor_metric_alert" "site_metric_alert_2" {
#   name                = "${local.resource_group_name}-web-availablity-and-ssl-expiration"
#   resource_group_name = local.resource_group_name
#   scopes              = [azurerm_application_insights_standard_web_test.url_web_test.id, azurerm_application_insights.app-insights.id]
#   description         = "Alert triggered when website is unavailable and/or SSL certificate is about to expire"
#   frequency           = "PT1M"
#   window_size         = "PT5M"
#   severity            = 1

#   application_insights_web_test_location_availability_criteria {
#     failed_location_count = 1
#     web_test_id           = azurerm_application_insights_standard_web_test.url_web_test.id
#     component_id          = azurerm_application_insights.app-insights.id
#   }

#   action {
#     action_group_id = azurerm_monitor_action_group.notification_group.id
#   }
# }