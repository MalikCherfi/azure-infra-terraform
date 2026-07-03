# ──────────────────────────────────────────────────────────────────────────────
# outputs.tf — Valeurs exposées après terraform apply
#
# Les outputs sont l'équivalent des `echo` à la fin de provision.sh.
# Complétez au fur et à mesure que vous créez les ressources.
# ──────────────────────────────────────────────────────────────────────────────

# TODO : URL de l'App Service
# output "app_service_url" {
#   description = "URL publique de l'App Service"
#   value       = "https://${module.app_service.default_hostname}"
# }

# TODO : URL de la Function App
# output "function_app_url" {
#   description = "URL publique de la Function App"
#   value       = "https://${module.function_app.default_hostname}"
# }

# TODO : FQDN du Container ACI
# output "container_fqdn" {
#   description = "FQDN public du container nginx"
#   value       = "http://${module.container.fqdn}"
# }

# TODO : Nom du Storage Account métier
# output "storage_account_name" {
#   description = "Nom du Storage Account"
#   value       = module.storage.storage_account_name
# }
