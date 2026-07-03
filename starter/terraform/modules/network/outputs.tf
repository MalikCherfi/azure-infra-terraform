output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_frontend_id" {
  value = azurerm_subnet.frontend.id
}

output "subnet_backend_id" {
  value = azurerm_subnet.backend.id
}
