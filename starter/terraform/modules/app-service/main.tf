terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# TODO : créer un azurerm_linux_web_app
#
# Nom attendu     : "app-${var.owner}-tf"
# Plan            : var.service_plan_id  (récupérer la location via un data source)
# HTTPS only      : true
# TLS minimum     : "1.2"
# Runtime         : Python 3.11
# Tags            : var.tags
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app

# resource "azurerm_linux_web_app" "app" {
#   name                = ???
#   resource_group_name = ???
#   location            = ???
#   service_plan_id     = ???
#   https_only          = ???
#
#   site_config {
#     minimum_tls_version = ???
#     application_stack {
#       python_version = ???
#     }
#   }
#
#   tags = ???
# }

# Indice : pour récupérer la location du plan partagé à partir de son ID,
# utilisez un data source azurerm_service_plan avec split("/", var.service_plan_id)
