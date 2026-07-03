terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# TODO (1/4) : créer un azurerm_virtual_network
#
# Nom            : "vnet-${var.owner}-tf"
# Espace d'adres.: ["10.0.0.0/16"]
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

# resource "azurerm_virtual_network" "vnet" {
#   name                = ???
#   resource_group_name = ???
#   location            = ???
#   address_space       = ???
#   tags                = ???
# }

# TODO (2/4) : créer deux subnets dans ce VNet
#
# subnet-frontend : 10.0.1.0/24
# subnet-backend  : 10.0.2.0/24
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

# resource "azurerm_subnet" "frontend" {
#   name                 = "subnet-frontend"
#   resource_group_name  = ???
#   virtual_network_name = ???
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_subnet" "backend" {
#   name                 = "subnet-backend"
#   resource_group_name  = ???
#   virtual_network_name = ???
#   address_prefixes     = ["10.0.2.0/24"]
# }

# TODO (3/4) : créer un NSG avec 3 règles pour subnet-frontend
#
# Nom    : "nsg-frontend-${var.owner}-tf"
# Règles : Allow-HTTP (100), Allow-HTTPS (110), Deny-All-Inbound (4000)
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

# resource "azurerm_network_security_group" "nsg" {
#   name                = ???
#   resource_group_name = ???
#   location            = ???
#   tags                = ???
#
#   # TODO : ajouter Allow-HTTP  (port 80,  priorité 100, action Allow)
#   # TODO : ajouter Allow-HTTPS (port 443, priorité 110, action Allow)
#   # TODO : ajouter Deny-All-Inbound (port *, priorité 4000, action Deny)
# }

# TODO (4/4) : associer le NSG au subnet-frontend
#
# Documentation : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association

# resource "azurerm_subnet_network_security_group_association" "frontend_nsg" {
#   subnet_id                 = ???
#   network_security_group_id = ???
# }
