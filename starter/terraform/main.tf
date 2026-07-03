# ──────────────────────────────────────────────────────────────────────────────
# main.tf — Ressources Azure à provisionner avec Terraform
#
# Ce fichier est votre point d'entrée. Complétez les TODO au fil du TP.
# ──────────────────────────────────────────────────────────────────────────────

# ── Tags communs à toutes les ressources ──────────────────────────────────────
# Ces tags sont mergés automatiquement dans chaque module via var.tags

locals {
  tags = merge(
    {
      managed_by  = "terraform"
      environment = "tp"
      owner       = var.owner
    },
    var.tags
  )
}

# ── Data sources ──────────────────────────────────────────────────────────────
# Un data source LIT une ressource existante sans la créer.

# Resource Group pré-créé par le formateur — ne jamais le gérer en Terraform
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Plan App Service partagé (dans un Resource Group séparé)
data "azurerm_service_plan" "shared" {
  name                = var.shared_plan_name
  resource_group_name = var.shared_rg_name
}

# ── Storage (Étape 2) ─────────────────────────────────────────────────────────
# TODO : appeler le module "./modules/storage"
# Paramètres à passer : owner, resource_group_name, location, tags

# module "storage" {
#   source = "./modules/storage"
#
#   owner               = ???
#   resource_group_name = ???
#   location            = ???
#   tags                = ???
# }

# ── App Service (Étape 3) ─────────────────────────────────────────────────────
# TODO : appeler le module "./modules/app-service"
# Paramètres à passer : owner, resource_group_name, service_plan_id, tags

# module "app_service" {
#   source = "./modules/app-service"
#
#   owner               = ???
#   resource_group_name = ???
#   service_plan_id     = ???   # récupéré depuis data.azurerm_service_plan.shared
#   tags                = ???
# }

# ── Function App (Étape 3) ────────────────────────────────────────────────────
# TODO : appeler le module "./modules/function-app"
# Paramètres à passer : owner, resource_group_name, location, service_plan_id, tags

# module "function_app" {
#   source = "./modules/function-app"
#
#   owner               = ???
#   resource_group_name = ???
#   location            = ???
#   service_plan_id     = ???
#   tags                = ???
# }

# ── Container Instance (Étape 3) ──────────────────────────────────────────────
# TODO : appeler le module "./modules/container"
# Paramètres à passer : owner, resource_group_name, location, tags

# module "container" {
#   source = "./modules/container"
#
#   owner               = ???
#   resource_group_name = ???
#   location            = ???
#   tags                = ???
# }

# ── Network (Étape 7) ─────────────────────────────────────────────────────────
# TODO : appeler le module "./modules/network"
# Paramètres à passer : owner, resource_group_name, location, tags

# module "network" {
#   source = "./modules/network"
#
#   owner               = ???
#   resource_group_name = ???
#   location            = ???
#   tags                = ???
# }
