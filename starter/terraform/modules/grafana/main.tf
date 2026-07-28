terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

data "azurerm_monitor_workspace" "prometheus" {
  name                = "amw-malik-cherfi"
  resource_group_name = var.resource_group_name
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_dashboard_grafana" "grafana" {
  name                  = "gm-${var.owner}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  grafana_major_version = "12"
  tags                  = var.tags

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = data.azurerm_monitor_workspace.prometheus.id
  }
}

resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.grafana.identity[0].principal_id
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "grafana_admin_self" {
  scope                = azurerm_dashboard_grafana.grafana.id
  role_definition_name = "Grafana Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_monitor_action_group" "ag" {
  name                = "ag-monitoring-${var.owner}"
  resource_group_name = var.resource_group_name
  short_name          = "alertmonit"

  email_receiver {
    name          = "owner"
    email_address = "malikcherfi@gmail.com"
  }
}

resource "azurerm_monitor_alert_prometheus_rule_group" "alerte_erreurs" {
  name                = "alerte-erreurs-${var.owner}"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = data.azurerm_monitor_workspace.prometheus.name
  scopes              = [data.azurerm_monitor_workspace.prometheus.id]
  rule_group_enabled  = true

  rule {
    enabled    = true
    expression = "log_erreurs_total > 5"
    severity   = 2
    alert      = "alerte-erreurs-${var.owner}"

    action {
      action_group_id = azurerm_monitor_action_group.ag.id
    }
  }
}

data "azurerm_application_insights" "appi" {
  name                = "appi-monitoring-${var.owner}"
  resource_group_name = var.resource_group_name
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alerte_taux_erreur" {
  name                 = "alerte-taux-erreur-${var.owner}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [azurerm_application_insights.appi.id]
  severity             = 2

  criteria {
    query                   = "requests | where success == false"
    time_aggregation_method = "Count"
    threshold               = 5
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.ag.id]
  }
}
