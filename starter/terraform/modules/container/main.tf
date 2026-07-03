terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# TODO : créer un azurerm_container_group (ACI)
#
# Nom attendu      : "aci-${var.owner}-tf"
# Image            : "nginx:latest"
# IP               : Public
# DNS label        : "aci-${var.owner}-tf"
# CPU / Mémoire    : 0.5 / 0.5
# Port             : 80 TCP
# OS               : Linux
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group

# resource "azurerm_container_group" "aci" {
#   name                = ???
#   resource_group_name = ???
#   location            = ???
#   ip_address_type     = ???
#   dns_name_label      = ???
#   os_type             = ???
#
#   container {
#     name   = "nginx"
#     image  = ???
#     cpu    = ???
#     memory = ???
#
#     ports {
#       port     = ???
#       protocol = "TCP"
#     }
#   }
#
#   tags = ???
# }
