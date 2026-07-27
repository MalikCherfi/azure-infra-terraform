terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_monitor_workspace" "amw" {
  name                = "amw-${var.owner}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_linux_virtual_machine" "vm_prometheus" {
  name                = "vm-prometheus-${var.owner}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  tags                = var.tags
  network_interface_ids = [
    var.prometheus_nic_id,
  ]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init-prometheus.yaml", {}))
}

resource "azurerm_role_assignment" "prometheus_publisher" {
  scope                = azurerm_monitor_workspace.amw.default_data_collection_rule_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_linux_virtual_machine.vm_prometheus.identity[0].principal_id
}

resource "azurerm_role_assignment" "prometheus_dce_reader" {
  scope                = azurerm_monitor_workspace.amw.default_data_collection_endpoint_id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_linux_virtual_machine.vm_prometheus.identity[0].principal_id
}

resource "azurerm_role_assignment" "prometheus_dcr_reader" {
  scope                = azurerm_monitor_workspace.amw.default_data_collection_rule_id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_linux_virtual_machine.vm_prometheus.identity[0].principal_id
}
