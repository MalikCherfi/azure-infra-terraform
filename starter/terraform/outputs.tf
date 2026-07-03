output "app_service_url" {
  description = "URL publique de l'App Service"
  value       = "https://${module.app_service.default_hostname}"
}

output "function_app_url" {
  description = "URL publique de la Function App"
  value       = "https://${module.function_app.default_hostname}"
}

output "container_fqdn" {
  description = "FQDN public du container nginx"
  value       = "http://${module.container.fqdn}"
}

output "storage_account_name" {
  description = "Nom du Storage Account"
  value       = module.storage.storage_account_name
}
