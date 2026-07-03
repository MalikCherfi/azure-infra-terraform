terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# TODO (1/3) : créer un azurerm_storage_account métier
#
# Nom attendu              : "st${replace(var.owner, "-", "")}tf"
# Tier                     : Standard, LRS, StorageV2, TLS 1.2
# Accès public blob activé : true  (nécessaire pour api-config)
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

# resource "azurerm_storage_account" "sa" {
#   name                            = ???
#   resource_group_name             = ???
#   location                        = ???
#   account_tier                    = ???
#   account_replication_type        = ???
#   account_kind                    = ???
#   min_tls_version                 = ???
#   allow_nested_items_to_be_public = ???   # true pour permettre api-config public
#   tags                            = ???
# }

# TODO (2/3) : conteneur privé pour les logs API
#
# Nom                  : "api-logs"
# container_access_type: "private"

# resource "azurerm_storage_container" "api_logs" {
#   name                  = ???
#   storage_account_id    = ???
#   container_access_type = ???
# }

# TODO (3/3) : conteneur public pour la config API
#
# Nom                  : "api-config"
# container_access_type: "blob"  (lecture anonyme des blobs, pas du container)

# resource "azurerm_storage_container" "api_config" {
#   name                  = ???
#   storage_account_id    = ???
#   container_access_type = ???
# }
