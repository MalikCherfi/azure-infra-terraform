terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# TODO (1/2) : créer un azurerm_storage_account dédié à la Function App
#
# La Function App a besoin d'un storage account propre (obligatoire Azure).
# Ce storage est SÉPARÉ du storage métier du module storage/.
#
# Nom attendu : "stfn${replace(var.owner, "-", "")}"
# Tier        : Standard, LRS, TLS 1.2
# Tags        : merge(var.tags, { purpose = "function-storage" })
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

# resource "azurerm_storage_account" "fn_storage" {
#   name                     = ???
#   resource_group_name      = ???
#   location                 = ???
#   account_tier             = ???
#   account_replication_type = ???
#   min_tls_version          = ???
#   tags                     = ???
# }

# TODO (2/2) : créer un azurerm_linux_function_app
#
# Nom attendu    : "fn-${var.owner}-tf"
# Plan           : var.service_plan_id
# Storage        : azurerm_storage_account.fn_storage.name + primary_access_key
# HTTPS only     : true
# Runtime        : Python 3.11
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app

# resource "azurerm_linux_function_app" "fn" {
#   name                       = ???
#   resource_group_name        = ???
#   location                   = ???
#   service_plan_id            = ???
#   storage_account_name       = ???
#   storage_account_access_key = ???
#   https_only                 = ???
#
#   site_config {
#     application_stack {
#       python_version = ???
#     }
#   }
#
#   tags = ???
# }
