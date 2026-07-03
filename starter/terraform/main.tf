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
module "storage" {
  source = "./modules/storage"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

}

# ── App Service (Étape 3) ─────────────────────────────────────────────────────
module "app_service" {
  source = "./modules/app-service"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = var.tags
}

# ── Function App (Étape 3) ────────────────────────────────────────────────────
module "function_app" {
  source = "./modules/function-app"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = var.tags
}

# ── Container Instance (Étape 3) ──────────────────────────────────────────────
module "container" {
  source = "./modules/container"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ── Network (Étape 7) ─────────────────────────────────────────────────────────
module "network" {
  source = "./modules/network"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
