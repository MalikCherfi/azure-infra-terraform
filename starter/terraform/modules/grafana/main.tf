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
  name                  = "grafana-monitoring-${var.owner}"
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
