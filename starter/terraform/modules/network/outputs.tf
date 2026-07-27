output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_frontend_id" {
  value = azurerm_subnet.frontend.id
}

output "subnet_backend_id" {
  value = azurerm_subnet.backend.id
}

output "prometheus_nic_id" {
  value = azurerm_network_interface.prometheus.id
}

output "prometheus_public_ip" {
  value = azurerm_public_ip.prometheus.ip_address
}
