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
    category = "MySqlSlowLogs"
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
  name                = "69b1e3bb-fc93-40be-83f2-98f6bec18ba0"
  resource_group_name = local.resource_group_name
  location            = local.location
  display_name        = "${local.resource_group_name}-workbook"
  source_id           = "${local.subscription_id}}"
  data_json = jsonencode({
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 1,
            "content": {
              "json": "---\r\n# Métriques du stockage"
            },
            "name": "texte - 0"
          },
          {
            "type": 10,
            "content": {
              "chartId": "workbook35dba9d4-cbdc-49fe-9f35-d8031c847581",
              "version": "MetricsItem/2.0",
              "size": 1,
              "chartType": 2,
              "resourceType": "microsoft.storage/storageaccounts",
              "metricScope": 0,
              "resourceIds": [
                "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
              ],
              "timeContext": {
                "durationMs": 3600000
              },
              "metrics": [
                {
                  "namespace": "microsoft.storage/storageaccounts",
                  "metric": "microsoft.storage/storageaccounts-Capacity-UsedCapacity",
                  "aggregation": 4,
                  "splitBy": null,
                  "columnName": "Capacité utilisée"
                }
              ],
              "gridSettings": {
                "rowLimit": 10000
              }
            },
            "name": "métrique - 1"
          },
          {
            "type": 10,
            "content": {
              "chartId": "workbook6f4f908c-15c5-484b-903a-5d8f511d0f1e",
              "version": "MetricsItem/2.0",
              "size": 1,
              "chartType": 2,
              "resourceType": "microsoft.storage/storageaccounts",
              "metricScope": 0,
              "resourceIds": [
                "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
              ],
              "timeContext": {
                "durationMs": 3600000
              },
              "metrics": [
                {
                  "namespace": "microsoft.storage/storageaccounts",
                  "metric": "microsoft.storage/storageaccounts-Transaction-Availability",
                  "aggregation": 4,
                  "splitBy": null,
                  "columnName": "Disponibilité"
                }
              ],
              "gridSettings": {
                "rowLimit": 10000
              }
            },
            "name": "métrique - 2"
          }
        ]
      },
      "name": "BDD - Copier - Copier"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 1,
            "content": {
              "json": "---\r\n# Métriques de la base de données"
            },
            "name": "texte - 0"
          },
          {
            "type": 10,
            "content": {
              "chartId": "workbook3f34abd3-339e-4233-9f28-121dd2631da7",
              "version": "MetricsItem/2.0",
              "size": 1,
              "chartType": 2,
              "color": "blue",
              "resourceType": "microsoft.dbformariadb/servers",
              "metricScope": 0,
              "resourceIds": [
                "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.DBforMariaDB/servers/${local.resource_group_name}-${local.server_name}"
              ],
              "timeContext": {
                "durationMs": 1800000
              },
              "metrics": [
                {
                  "namespace": "microsoft.dbformariadb/servers",
                  "metric": "microsoft.dbformariadb/servers-Traffic-active_connections",
                  "aggregation": 4,
                  "splitBy": null,
                  "columnName": "Backup storage "
                }
              ],
              "gridFormatType": 1,
              "tileSettings": {
                "showBorder": false,
                "titleContent": {
                  "columnMatch": "Name",
                  "formatter": 13
                },
                "leftContent": {
                  "columnMatch": "Value",
                  "formatter": 12,
                  "formatOptions": {
                    "palette": "auto"
                  },
                  "numberFormat": {
                    "unit": 17,
                    "options": {
                      "maximumSignificantDigits": 3,
                      "maximumFractionDigits": 2
                    }
                  }
                }
              },
              "mapSettings": {
                "locInfo": "AzureResource",
                "sizeSettings": "Backup storage ",
                "sizeAggregation": "Sum",
                "legendMetric": "Backup storage ",
                "legendAggregation": "Sum",
                "itemColorSettings": {
                  "type": "heatmap",
                  "colorAggregation": "Sum",
                  "nodeColorField": "Backup storage ",
                  "heatmapPalette": "greenRed"
                },
                "locInfoColumn": "Name"
              },
              "graphSettings": {
                "type": 0,
                "topContent": {
                  "columnMatch": "Subscription",
                  "formatter": 1
                },
                "centerContent": {
                  "columnMatch": "Value",
                  "formatter": 1,
                  "numberFormat": {
                    "unit": 17,
                    "options": {
                      "maximumSignificantDigits": 3,
                      "maximumFractionDigits": 2
                    }
                  }
                }
              },
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "Subscription",
                    "formatter": 5
                  },
                  {
                    "columnMatch": "Name",
                    "formatter": 13,
                    "formatOptions": {
                      "linkTarget": "Resource"
                    }
                  },
                  {
                    "columnMatch": "Backup storage  Timeline",
                    "formatter": 5
                  },
                  {
                    "columnMatch": "microsoft.dbformariadb/servers-Saturation-backup_storage_used",
                    "formatter": 1,
                    "numberFormat": {
                      "unit": 2,
                      "options": null
                    }
                  }
                ],
                "rowLimit": 10000,
                "labelSettings": [
                  {
                    "columnId": "Backup storage ",
                    "label": "Backup storage "
                  },
                  {
                    "columnId": "Backup storage  Timeline",
                    "label": "Backup storage  Timeline"
                  }
                ]
              }
            },
            "name": "métrique - 2"
          },
          {
            "type": 10,
            "content": {
              "chartId": "workbookb0d5f5af-9df2-4ea5-b9f9-2e553472bd5e",
              "version": "MetricsItem/2.0",
              "size": 1,
              "chartType": 2,
              "color": "blue",
              "resourceType": "microsoft.dbformariadb/servers",
              "metricScope": 0,
              "resourceIds": [
                "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.DBforMariaDB/servers/${local.resource_group_name}-${local.server_name}"
              ],
              "timeContext": {
                "durationMs": 3600000
              },
              "metrics": [
                {
                  "namespace": "microsoft.dbformariadb/servers",
                  "metric": "microsoft.dbformariadb/servers-Saturation-storage_percent",
                  "aggregation": 4,
                  "splitBy": null,
                  "columnName": "Stockage %"
                }
              ],
              "gridSettings": {
                "rowLimit": 10000
              }
            },
            "name": "métrique - 2"
          },
          {
            "type": 10,
            "content": {
              "chartId": "workbook1b5b64f4-5e62-4413-b15b-aaa2ac57329b",
              "version": "MetricsItem/2.0",
              "size": 1,
              "chartType": 2,
              "color": "blue",
              "resourceType": "microsoft.dbformariadb/servers",
              "metricScope": 0,
              "resourceIds": [
                "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.DBforMariaDB/servers/${local.resource_group_name}-${local.server_name}"
              ],
              "timeContext": {
                "durationMs": 3600000
              },
              "metrics": [
                {
                  "namespace": "microsoft.dbformariadb/servers",
                  "metric": "microsoft.dbformariadb/servers-Errors-connections_failed",
                  "aggregation": 1,
                  "splitBy": null,
                  "columnName": "Erreur de connexion"
                }
              ],
              "gridSettings": {
                "rowLimit": 10000
              }
            },
            "name": "métrique - 3"
          }
        ]
      },
      "name": "BDD"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 1,
            "content": {
              "json": "---\r\n# Métriques des VMs"
            },
            "name": "texte - 0"
          },
          {
            "type": 10,
            "content": {
              "chartId": "workbooke9eba9b3-f5d7-4ac6-b51f-2b9763bcd154",
              "version": "MetricsItem/2.0",
              "size": 1,
              "chartType": 2,
              "resourceType": "microsoft.compute/virtualmachines",
              "metricScope": 0,
              "resourceIds": [
                "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${local.resource_group_name}-vm-${local.bastion_name}",
                "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${local.resource_group_name}-vm-${local.appli_name}"
              ],
              "timeContext": {
                "durationMs": 3600000
              },
              "metrics": [
                {
                  "namespace": "microsoft.compute/virtualmachines",
                  "metric": "microsoft.compute/virtualmachines--Percentage CPU",
                  "aggregation": 4,
                  "splitBy": null,
                  "columnName": "CPU %"
                }
              ],
              "gridSettings": {
                "rowLimit": 10000
              }
            },
            "name": "métrique - 1"
          },
          {
            "type": 10,
            "content": {
              "chartId": "workbooke7bbe1ab-6b7e-449b-b418-88d7fd7d9d83",
              "version": "MetricsItem/2.0",
              "size": 1,
              "chartType": 2,
              "color": "grayBlue",
              "resourceType": "microsoft.compute/virtualmachinescalesets",
              "metricScope": 0,
              "resourceIds": [
                "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Compute/virtualMachineScaleSets/${local.resource_group_name}-${local.scale_name}"
              ],
              "timeContext": {
                "durationMs": 3600000
              },
              "metrics": [
                {
                  "namespace": "microsoft.compute/virtualmachinescalesets",
                  "metric": "microsoft.compute/virtualmachinescalesets--Percentage CPU",
                  "aggregation": 4,
                  "splitBy": null,
                  "columnName": "CPU %"
                }
              ],
              "gridSettings": {
                "rowLimit": 10000
              }
            },
            "name": "métrique - 2"
          }
        ]
      },
      "name": "BDD - Copier"
    }
  ],
  "fallbackResourceIds": [
    "${local.subscription_id}}"
  ],
  "$schema": "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
})
}

# Creation of an action group to manage alert notifications
resource "azurerm_monitor_action_group" "notification_group" {
  name                = "${local.resource_group_name}-notification-group"
  resource_group_name = local.resource_group_name
  short_name          = "notifgrp"

  dynamic "email_receiver" {
    for_each = local.users

    content {
      name          = "email-${email_receiver.value.name}"
      email_address = email_receiver.value.email
    }
  }
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
  scopes              = [azurerm_storage_account.wiki-account.id]
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
  scopes              = [azurerm_linux_virtual_machine.VM_Appli.id]
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
  scopes              = [azurerm_application_gateway.main.id]
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