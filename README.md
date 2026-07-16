# Azure Infra Terraform

Infrastructure Azure gérée en IaC avec Terraform, déployée automatiquement via GitHub Actions avec authentification OIDC (sans secret longue durée).

## Sommaire

- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Structure du projet](#structure-du-projet)
- [Setup initial (bootstrap)](#setup-initial-bootstrap)
- [Utilisation en local](#utilisation-en-local)
- [CI/CD](#cicd)
- [Variables & secrets GitHub](#variables--secrets-github)
- [Dependabot](#dependabot)

## Architecture

L'infrastructure provisionne, dans un Resource Group Azure dédié :

| Module | Ressources |
|---|---|
| `oidc` | Managed Identity + Federated Identity Credentials (GitHub OIDC) + Role Definition/Assignment custom |
| `storage` | Storage Account + containers |
| `app-service` | App Service (Linux Web App, Python 3.11) |
| `function-app` | Function App |
| `container` | Container App / Container Instance |
| `network` | VNet, Subnets, Network Security Groups |

Le state Terraform est stocké à distance sur **Azure Blob Storage** (backend `azurerm`), avec verrouillage automatique pour éviter les écritures concurrentes.

L'authentification entre GitHub Actions et Azure se fait via **OIDC** (OpenID Connect) : aucun secret longue durée n'est stocké, GitHub échange un token à courte durée de vie contre un accès Azure via la Managed Identity fédérée.

## Prérequis

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.9`
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Un compte Azure avec les droits suffisants sur la souscription cible
- Accès en écriture au repo GitHub (pour la CI/CD)

## Structure du projet

```
.
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # Validation (fmt, Checkov, validate, plan) sur push/PR
│   │   └── terraform.yml             # Apply/Destroy manuel via workflow_dispatch
│   └── dependabot.yml                 # Mises à jour auto (providers Terraform + actions GitHub)
└── starter/terraform/
    ├── modules/
    │   ├── oidc/                      # Managed Identity + Federated Credentials + RBAC
    │   ├── storage/                   # Storage Account
    │   ├── app-service/                # App Service (Linux Web App)
    │   ├── function-app/               # Function App
    │   ├── container/                  # Container App
    │   └── network/                    # VNet, Subnets, NSG
    ├── backend.tf                      # Déclaration du backend azurerm (vide, rempli via -backend-config)
    ├── backend.hcl                     # Config du backend (non commité, contient les valeurs réelles)
    ├── main.tf                         # Point d'entrée, appelle tous les modules
    ├── variables.tf                    # Variables du module racine
    ├── outputs.tf                      # Outputs exposés (ex: client_id de la managed identity)
    ├── providers.tf                    # Configuration du provider azurerm
    ├── terraform.tfvars                # Valeurs des variables (non commité)
    └── .tflint.hcl                     # Config du linter TFLint
```

## Setup initial (bootstrap)

Le backend Terraform (Storage Account + container pour stocker le state) doit être créé **avant** tout `terraform init`, car Terraform ne peut pas créer l'endroit où il va lui-même stocker son état.

```bash
./bootstrap-backend.sh
```

Ce script crée :
- le Storage Account
- le container `tfstate` dedans

Une fois créé, configure `starter/terraform/backend.hcl` avec les valeurs correspondantes (non commité, voir `.gitignore`).

## Utilisation en local

```bash
cd starter/terraform

# Connexion Azure
az login
az account set --subscription "<subscription-id>"

# Initialisation avec le backend distant
terraform init -backend-config=backend.hcl

# Vérifications
terraform fmt -check -recursive
terraform validate

# Aperçu des changements
terraform plan

# Application
terraform apply
```

### Variables à renseigner

Copie tes valeurs dans `starter/terraform/terraform.tfvars` (fichier non commité) :

```hcl
owner               = "ton-nom"
resource_group_name = "rg-ton-nom"
location            = "francecentral"
plan_name           = "plan-ton-nom"
tags = {
  project = "tp-azure"
}
```

## CI/CD

### `ci.yml` — Validation continue

Se déclenche sur chaque `push` et `pull_request` vers `main` :

1. **Terraform Format Check** — vérifie le formatage (`fmt -check`)
2. **Checkov** — scan de sécurité/conformité IaC (`soft_fail: true`, n'échoue jamais le job)
3. **Terraform Init** — initialise le backend distant
4. **Terraform Validate** — vérifie la cohérence de la config
5. **Terraform Plan** — calcule les changements prévus

Ce workflow ne modifie **jamais** l'infrastructure réelle : il valide uniquement.

### `terraform.yml` — Apply / Destroy manuel

Déclenché **manuellement** via l'onglet **Actions → Terraform workflow dispatch → Run workflow**, avec un choix explicite :
- `apply` : plan + apply de l'infrastructure
- `destroy` : destruction complète de l'infrastructure

⚠️ Le `destroy` n'est jamais automatique — toujours un geste volontaire depuis l'interface GitHub.

## Variables & secrets GitHub

À configurer dans **Settings → Secrets and variables → Actions** du repo.

### Secrets (sensibles)

| Nom | Description |
|---|---|
| `AZURE_CLIENT_ID` | Client ID de la Managed Identity OIDC |
| `AZURE_TENANT_ID` | Tenant ID Azure AD |
| `AZURE_SUBSCRIPTION_ID` | ID de la souscription Azure |
| `AZURE_RESOURCE_GROUP` | Resource Group contenant le backend Terraform |
| `AZURE_SA_NAME` | Nom du Storage Account du backend |
| `AZURE_CONTAINER_NAME` | Nom du container Blob (`tfstate`) |
| `TFSTATE_KEY` | Nom du blob de state (`<owner>.terraform.tfstate`) |

### Variables (non sensibles)

| Nom | Description |
|---|---|
| `TF_VAR_OWNER` | Identifiant du propriétaire des ressources |
| `TF_VAR_RESOURCE_GROUP_NAME` | Resource Group cible pour l'infra applicative |
| `TF_VAR_LOCATION` | Région Azure de déploiement |
| `TF_VAR_PLAN_NAME` | Nom de l'App Service Plan |

## Dependabot

`.github/dependabot.yml` surveille automatiquement, avec des PR ouvertes quotidiennement :
- les versions des **providers Terraform** (`azurerm`, etc.)
- les versions des **actions GitHub** utilisées dans les workflows (`azure/login`, `hashicorp/setup-terraform`, etc.)