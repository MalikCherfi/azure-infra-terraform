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

output "app_insights_connection_string" {
  value     = module.application_insights.app_insights_connection_string
  sensitive = true
}

output "network_ip_prometheus" {
  value = module.network.prometheus_nic_id
}

output "prometheus_public_ip" {
  value = module.network.prometheus_public_ip
}

output "grafana_endpoint" {
  value = module.grafana.grafana_endpoint
}
