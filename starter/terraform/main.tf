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


data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_service_plan" "plan" {
  name                = var.plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

module "oidc" {
  source = "./modules/oidc"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags
}

# ── Storage (Étape 2) ─────────────────────────────────────────────────────────
module "storage" {
  source = "./modules/storage"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags

}

# ── App Service (Étape 3) ─────────────────────────────────────────────────────
module "app_service" {
  source = "./modules/app-service"

  owner               = var.owner
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id
  tags                = local.tags
  app_insights_connection_string  = module.application_insights.app_insights_connection_string
}

# ── Function App (Étape 3) ────────────────────────────────────────────────────
module "function_app" {
  source = "./modules/function-app"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan.id
  tags                = local.tags
}

# ── Container Instance (Étape 3) ──────────────────────────────────────────────
module "container" {
  source = "./modules/container"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags
}

# ── Network (Étape 7) ─────────────────────────────────────────────────────────
module "network" {
  source = "./modules/network"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags
}

module "application_insights" {
  source = "./modules/application-insights"

  owner               = var.owner
  resource_group_name = var.resource_group_name
  tags                = local.tags
}
