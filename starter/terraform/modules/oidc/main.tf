terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

data "azurerm_subscription" "primary" {
}


resource "azurerm_user_assigned_identity" "oidc" {
  location            = var.location
  name                = var.managed_identity_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_federated_identity_credential" "github-federated-identity-main" {
  name                      = var.fic_main_name
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  user_assigned_identity_id = azurerm_user_assigned_identity.oidc.id
  subject                   = "repo:MalikCherfi/azure-infra-terraform:ref:refs/heads/main"
}

resource "azurerm_federated_identity_credential" "github-federated-identity-feat-terraform-config" {
  name                      = var.fic_feat_name
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  user_assigned_identity_id = azurerm_user_assigned_identity.oidc.id
  subject                   = "repo:MalikCherfi/azure-infra-terraform:ref:refs/heads/feat/terraform-config"
}

resource "azurerm_federated_identity_credential" "github-federated-identity-pr" {
  name                      = var.fic_pr_name
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  user_assigned_identity_id = azurerm_user_assigned_identity.oidc.id
  subject                   = "repo:MalikCherfi/azure-infra-terraform:pull_request"
}

locals {
  role_definition_name = "${var.role_definition_name}-${var.resource_group_name}"
}

resource "azurerm_role_definition" "role-definition" {
  name        = local.role_definition_name
  scope       = data.azurerm_subscription.primary.id
  description = "Peut créer / gérer des app services, containers, des fonctions Azure, des comptes de stockage et des réseaux virtuels"

  permissions {
    actions = [
      "Microsoft.App/containerApps/*",
      "Microsoft.App/managedEnvironments/*",
      "Microsoft.ContainerRegistry/registries/*",
      "Microsoft.ContainerInstance/containerGroups/read",
      "Microsoft.OperationalInsights/workspaces/*",
      "Microsoft.OperationalInsights/workspaces/sharedKeys/action",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Storage/storageAccounts/*",
      "Microsoft.Network/virtualNetworks/*",
      "Microsoft.Network/virtualNetworks/subnets/*",
      "Microsoft.Network/networkSecurityGroups/*",
      "Microsoft.Network/networkSecurityGroups/join/action",
      "Microsoft.Web/sites/*",
      "Microsoft.Web/serverfarms/*",
      "Microsoft.Web/sites/config/*",
      "Microsoft.ManagedIdentity/userAssignedIdentities/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read",
      "Microsoft.Authorization/roleAssignments/read",
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_role_assignment" "role-assignment" {
  scope              = data.azurerm_resource_group.rg.id
  role_definition_id = azurerm_role_definition.role-definition.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.oidc.principal_id
}
