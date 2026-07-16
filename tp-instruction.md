# TP Terraform — Infrastructure as Code sur Azure

**Durée :** 2 jours (12h)  
**Niveau :** Débutant-Intermédiaire — avoir terminé les TPs CLI Azure (Module 3 Stockage + Module 4 Réseau)  
**Prérequis :** Git, VS Code, Azure CLI, compte Azure actif

> 💡 **Lien avec le TP CLI :** vous avez déjà créé un App Service, une Function App et un Container avec `az CLI`. Dans ce TP, vous allez faire **exactement la même chose**, mais en décrivant ces ressources dans des fichiers Terraform. La différence : votre infrastructure devient du code versionné, reproductible, et déployable automatiquement.

---

## Mise en place

### A — Préparer votre repo `azure-infra-terraform`

Créez un repo **privé** sur votre GitHub nommé `azure-infra-terraform`, puis clonez-le :

```bash
git clone https://github.com/<votre-username>/azure-infra-terraform.git
cd azure-infra-terraform
git checkout -b feat/terraform-resources
```

### B — Copier le starter dans votre repo

Le formateur met à disposition un dossier `starter/` dans le repo de formation (`tp-terraform`). Copiez son contenu dans votre repo :

```bash
# Depuis le dossier tp-terraform du formateur
cp -r starter/.gitignore        ../azure-infra-terraform/
cp -r starter/.github           ../azure-infra-terraform/
cp -r starter/terraform         ../azure-infra-terraform/

cd ../azure-infra-terraform
ls terraform/
# backend.tf  main.tf  modules/  outputs.tf  providers.tf  variables.tf
```

> ℹ️ Le starter vous donne la structure et le boilerplate. Vous allez compléter les `# TODO` au fil du TP.

### C — Installer Terraform

**macOS :**
```bash
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
```

**Windows :**
```powershell
winget install HashiCorp.Terraform
```

**Linux :**
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

```bash
terraform --version   # Terraform v1.9.x
```

### D — Extensions VS Code

| Extension | Utilité |
|-----------|---------|
| **HashiCorp Terraform** | Coloration syntaxique, autocomplétion HCL |
| **Azure Terraform** | Intégration Azure |

### E — Se connecter à Azure

```bash
az login
az account show --output table
```

---

## Jour 1 — Les fondamentaux Terraform (6h)

---

## Étape 1 — Comprendre l'Infrastructure as Code (45 min)

> 🎯 **Pourquoi on fait ça ?**
> Jusqu'ici vous avez créé des ressources Azure avec `az`. C'est rapide pour tester, mais personne ne sait exactement ce qui existe, vous ne pouvez pas recréer l'environnement facilement, et les changements ne sont pas tracés dans Git. Terraform résout tout ça : l'infrastructure est décrite dans des fichiers texte versionnés, reproductibles et auditables.

### Concept — CLI vs Terraform

```bash
# CLI — impératif : vous dites COMMENT faire
az webapp create --name "app-jean-cli" --plan "$APP_PLAN"

# Terraform — déclaratif : vous décrivez CE QUE vous voulez
resource "azurerm_linux_web_app" "app" {
  name            = "app-jean-tf"
  service_plan_id = data.azurerm_service_plan.shared.id
}
```

**Les avantages clés :**
- **Reproductible** : le même code crée exactement la même infrastructure
- **Versionné** : les changements d'infra sont tracés dans Git comme du code
- **Idempotent** : relancer `terraform apply` deux fois ne crée pas deux fois la ressource

### Le cycle de vie

```
terraform init      → télécharge les providers
terraform plan      → compare état actuel vs code → affiche les différences
terraform apply     → applique les changements
terraform destroy   → supprime toutes les ressources
```

### La syntaxe HCL

```hcl
# resource : CRÉE une ressource Azure
resource "azurerm_storage_account" "sa" {
  name                = "stjeandupont"
  resource_group_name = "rg-jean-dupont"
  location            = "francecentral"
}

# data : LIT une ressource existante (sans la créer)
data "azurerm_resource_group" "rg" {
  name = "rg-jean-dupont"
}
```

---

### Exercice 1.1 — Explorer le starter

Ouvrez `terraform/providers.tf` dans VS Code et répondez :

1. Quelle version du provider Azure est utilisée ?
2. Que signifie `use_oidc = true` ?
3. À quoi sert le bloc `features {}` ?

Puis initialisez Terraform :

```bash
cd terraform/
terraform init
```

<details>
<summary>💡 Correction</summary>

**1.** `~> 4.0` : version 4.x (compatible mineur, refuse 5.0).

**2.** `use_oidc = true` : Terraform s'authentifie à Azure via un token JWT signé par GitHub — pas de `CLIENT_SECRET` stocké en dur.

**3.** `features {}` : bloc obligatoire pour le provider Azure, même vide. Il permet de configurer des comportements avancés (soft delete, purge protection...).

</details>

---

### Exercice 1.2 — Explorer `variables.tf` et `main.tf`

Ouvrez `terraform/variables.tf` et `terraform/main.tf`. Repérez :

1. Quelles variables sont obligatoires (sans valeur par défaut) ?
2. Dans `main.tf`, que font les deux blocs `data` déjà écrits ?
3. Que signifie `local.tags` et d'où vient-il ?

<details>
<summary>💡 Correction</summary>

**1.** `owner` et `resource_group_name` sont sans `default` → Terraform les demandera interactivement.

**2.** Les deux `data` sources lisent sans créer :
- `data.azurerm_resource_group.rg` : lit votre resource group (créé par le formateur)
- `data.azurerm_service_plan.shared` : lit le plan App Service partagé

**3.** `locals` dans `main.tf` construit `local.tags` en fusionnant des tags communs avec `var.tags`. Toutes les ressources utilisent `tags = local.tags` pour être taggées `managed_by=terraform`.

</details>

---

### Exercice 1.3 — Créer `terraform.tfvars`

Créez `terraform/terraform.tfvars` (il est dans le `.gitignore` — ne jamais le commiter) :

```hcl
owner               = "prenom-nom"        # votre identifiant
resource_group_name = "rg-prenom-nom"     # votre resource group
```

```bash
terraform plan   # doit afficher "0 to add" — les data sources ne créent rien
```

<details>
<summary>💡 Correction</summary>

`terraform plan` avec seulement des `data` sources affiche :

```
No changes. Your infrastructure matches the configuration.
```

C'est attendu : un `data` source lit sans modifier. Vous verrez des changements dès que vous ajouterez des `resource`.

</details>

---

## Étape 2 — Votre premier module : Storage (1h)

> 🎯 **Pourquoi des modules ?**
> En Terraform professionnel, on ne met jamais des dizaines de `resource` dans un seul `main.tf`. On organise le code en **modules** — des dossiers réutilisables, chacun responsable d'une partie de l'infrastructure. Dans votre starter, chaque ressource Azure a son module : `modules/storage/`, `modules/app-service/`, etc.

### Concept — Anatomie d'un module

```
modules/storage/
├── variables.tf    ← paramètres d'entrée (owner, location, tags...)
├── main.tf         ← les ressources du module (storage account, containers...)
└── outputs.tf      ← valeurs exposées après création (nom, ID...)
```

**Appeler un module depuis `main.tf` :**

```hcl
module "storage" {
  source              = "./modules/storage"
  owner               = var.owner               # passage des variables
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags
}
```

---

### Exercice 2.1 — Lire `modules/storage/variables.tf`

Ouvrez le fichier. Quelles variables le module attend-il ? Pourquoi ne sont-elles pas déclarées dans le `variables.tf` racine ?

<details>
<summary>💡 Correction</summary>

Le module attend : `owner`, `resource_group_name`, `location`, `tags`.

Ces variables sont **locales au module** — elles ne remontent pas au `variables.tf` racine. Quand `main.tf` appelle le module, il passe les valeurs depuis le contexte racine (`var.owner`, `data.azurerm_resource_group.rg.name`...). C'est le principe d'encapsulation : chaque module déclare ce dont il a besoin.

</details>

---

### Exercice 2.2 — Remplir `modules/storage/main.tf`

Ouvrez `modules/storage/main.tf`. Vous y trouvez 3 `TODO`. Complétez-les :

**TODO 1** — Storage Account métier :
- Nom : `"st${replace(var.owner, "-", "")}tf"`
- Tier : Standard, LRS, StorageV2, TLS 1.2
- `allow_nested_items_to_be_public = true` (nécessaire pour api-config)

**TODO 2** — Conteneur privé `api-logs` (`container_access_type = "private"`)

**TODO 3** — Conteneur public `api-config` (`container_access_type = "blob"`)

Documentation : [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)

<details>
<summary>💡 Correction</summary>

```hcl
resource "azurerm_storage_account" "sa" {
  name                            = "st${replace(var.owner, "-", "")}tf"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = true
  tags                            = var.tags
}

resource "azurerm_storage_container" "api_logs" {
  name                  = "api-logs"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "api_config" {
  name                  = "api-config"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "blob"
}
```

**Pourquoi `storage_account_id` et pas `storage_account_name` ?**  
Le provider Azure 4.x préfère les IDs (plus stables que les noms). `azurerm_storage_account.sa.id` référence l'objet créé juste au-dessus — Terraform résout automatiquement la dépendance.

</details>

---

### Exercice 2.3 — Remplir `modules/storage/outputs.tf`

Exposez le nom du Storage Account pour pouvoir l'afficher dans les outputs racine.

<details>
<summary>💡 Correction</summary>

```hcl
output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}
```

</details>

---

### Exercice 2.4 — Activer le module dans `main.tf`

Dans `terraform/main.tf`, décommentez le bloc `module "storage"` et remplacez les `???` par les bonnes valeurs.

```bash
terraform fmt
terraform validate
terraform plan    # doit afficher "3 to add" (SA + 2 containers)
```

<details>
<summary>💡 Correction</summary>

```hcl
module "storage" {
  source              = "./modules/storage"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags
}
```

Après `terraform init` (obligatoire quand on ajoute un module) :
```bash
terraform init    # enregistre le nouveau module
terraform plan    # 3 to add : storage account + api-logs + api-config
terraform apply
```

</details>

---

## Étape 3 — App Service, Function App, Container (1h30)

> 🎯 **Pourquoi on fait ça ?**
> Vous avez déjà créé ces trois ressources en CLI. Ici, vous écrivez les mêmes ressources en HCL dans leurs modules respectifs. La logique est identique — seule la syntaxe change.

---

### Exercice 3.1 — `modules/app-service/main.tf`

Complétez le module App Service. Le plan partagé est passé via `var.service_plan_id`.

Contraintes : Python 3.11, HTTPS only, TLS 1.2.

Documentation : [`azurerm_linux_web_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app)

<details>
<summary>💡 Correction</summary>

```hcl
resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_service_plan.plan.location
  service_plan_id     = var.service_plan_id
  https_only          = true

  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      python_version = "3.11"
    }
  }

  tags = var.tags
}

# Data source pour récupérer la location du plan depuis son ID
data "azurerm_service_plan" "plan" {
  name                = split("/", var.service_plan_id)[8]
  resource_group_name = split("/", var.service_plan_id)[4]
}
```

**Dans `outputs.tf` :**
```hcl
output "default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}
```

</details>

---

### Exercice 3.2 — `modules/function-app/main.tf`

La Function App a besoin d'un **storage account dédié** (obligatoire Azure, séparé du storage métier).

Créez les deux ressources : `azurerm_storage_account` (nommé `stfn${replace(var.owner, "-", "")}`) puis `azurerm_linux_function_app`.

Documentation : [`azurerm_linux_function_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app)

<details>
<summary>💡 Correction</summary>

```hcl
resource "azurerm_storage_account" "fn_storage" {
  name                     = "stfn${replace(var.owner, "-", "")}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = merge(var.tags, { purpose = "function-storage" })
}

resource "azurerm_linux_function_app" "fn" {
  name                       = "fn-${var.owner}-tf"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = var.service_plan_id
  storage_account_name       = azurerm_storage_account.fn_storage.name
  storage_account_access_key = azurerm_storage_account.fn_storage.primary_access_key
  https_only                 = true

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  tags = var.tags
}
```

**Dans `outputs.tf` :**
```hcl
output "default_hostname" {
  value = azurerm_linux_function_app.fn.default_hostname
}
```

**Correspondance CLI → Terraform :**
| `az functionapp create` | `azurerm_linux_function_app` |
|------------------------|------------------------------|
| `--storage-account` | `storage_account_name` |
| `--plan` | `service_plan_id` |
| `--runtime python --runtime-version 3.11` | `application_stack { python_version = "3.11" }` |

</details>

---

### Exercice 3.3 — `modules/container/main.tf`

Déployez un container `nginx:latest` accessible publiquement via un FQDN Azure.

Documentation : [`azurerm_container_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group)

<details>
<summary>💡 Correction</summary>

```hcl
resource "azurerm_container_group" "aci" {
  name                = "aci-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_address_type     = "Public"
  dns_name_label      = "aci-${var.owner}-tf"
  os_type             = "Linux"

  container {
    name   = "nginx"
    image  = "nginx:latest"
    cpu    = 0.5
    memory = 0.5

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = var.tags
}
```

**Dans `outputs.tf` :**
```hcl
output "fqdn" {
  value = azurerm_container_group.aci.fqdn
}
```

</details>

---

### Exercice 3.4 — Activer les 3 modules dans `main.tf`

Décommentez les blocs `module "app_service"`, `module "function_app"` et `module "container"` dans `terraform/main.tf`. Remplacez les `???`.

```bash
terraform init    # re-init pour enregistrer les nouveaux modules
terraform plan    # combien de ressources vont être créées ?
```

<details>
<summary>💡 Correction</summary>

```hcl
module "app_service" {
  source              = "./modules/app-service"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = local.tags
}

module "function_app" {
  source              = "./modules/function-app"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = local.tags
}

module "container" {
  source              = "./modules/container"
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags
}
```

Le plan doit afficher **6 to add** : App Service + Function App + son storage + Container + le data source du plan.

</details>

---

## Étape 4 — Outputs et premier apply complet (45 min)

> 🎯 **Pourquoi on fait ça ?**
> Les outputs sont l'équivalent des `echo` à la fin de `provision.sh`. Ils exposent les URLs et FQDNs après le `apply` — sans avoir à fouiller le portail Azure.

### Exercice 4.1 — Remplir `outputs.tf`

Dans `terraform/outputs.tf`, décommentez et complétez les 4 outputs en utilisant `module.<nom>.<output>`.

<details>
<summary>💡 Correction</summary>

```hcl
output "app_service_url" {
  description = "URL de l'App Service"
  value       = "https://${module.app_service.default_hostname}"
}

output "function_app_url" {
  description = "URL de la Function App"
  value       = "https://${module.function_app.default_hostname}"
}

output "container_fqdn" {
  description = "FQDN du container nginx"
  value       = "http://${module.container.fqdn}"
}

output "storage_account_name" {
  description = "Nom du Storage Account"
  value       = module.storage.storage_account_name
}
```

</details>

---

### Exercice 4.2 — Plan, apply, vérification

```bash
terraform fmt
terraform validate
terraform plan    # vérifiez le récapitulatif avant d'appliquer
terraform apply
```

Après l'apply, vous devez voir les 4 outputs avec vos URLs. Testez l'URL du container dans un navigateur.

---

### Exercice 4.3 — Observer le state

Ouvrez `terraform.tfstate` et répondez :

1. Que contient ce fichier ?
2. Que se passe-t-il si vous le supprimez et relancez `terraform plan` ?
3. Pourquoi ne faut-il jamais le commiter ? (regardez s'il contient des valeurs sensibles)

<details>
<summary>💡 Correction</summary>

**1.** `terraform.tfstate` est un JSON avec l'état exact de toutes les ressources gérées : ID Azure, attributs, dépendances. C'est la "mémoire" de Terraform.

**2.** Terraform croit que rien n'existe → affiche `6 to add` → tente de recréer → erreur Azure "resource already exists".

**3.** Le state peut contenir des **clés d'accès en clair** (comme `primary_access_key` du storage de la Function App). Solution : le **remote state** dans Azure Blob Storage (Étape 6).

</details>

---

### Exercice 4.4 — Modifier et détruire

Changez l'image du container de `nginx:latest` à `nginx:1.25` dans `modules/container/main.tf`.

1. Lancez `terraform plan`. Est-ce un update ou une recréation (`~` ou `-/+`) ?
2. Lancez `terraform destroy`.

<details>
<summary>💡 Correction</summary>

```
-/+ azurerm_container_group.aci must be replaced
  ~ container[0].image = "nginx:latest" → "nginx:1.25"
```

Un changement d'image ACI est un **destroy + recreate** (`-/+`) — Azure ne peut pas modifier l'image d'un container en cours d'exécution.

Les symboles du plan :
- `+` create, `-` destroy, `~` update in-place, `-/+` destroy and recreate

</details>

---

## Étape 5 — Exercice fil rouge Jour 1 (45 min)

> 🎯 Recréez l'infrastructure complète et committez sur votre branche.

```bash
terraform apply   # recréer après le destroy

terraform fmt
terraform validate
```

Vérifiez que vous avez bien les 4 outputs avec vos URLs.

**Committez :**

```bash
git add terraform/
git commit -m "feat(terraform): infrastructure AzureTech — Storage + App Service + Function App + Container"
git push origin feat/terraform-resources
```

Ouvrez une Pull Request sur votre repo `azure-infra-terraform`. Le workflow `.github/workflows/terraform.yml` déclenchera un `terraform plan` automatique commenté sur la PR.

---

## Jour 2 — Terraform en équipe (6h)

---

## Étape 6 — Remote State dans Azure Blob Storage (1h30)

> 🎯 **Pourquoi on fait ça ?**
> Le state local pose un problème fondamental : si vous travaillez depuis deux machines, vos states divergent. Le remote state stocke le fichier dans Azure Blob Storage — partagé, sécurisé, avec verrouillage automatique.

### Concept

```
State local (problématique)           State remote (bonne pratique)
┌─────────────────────────┐           ┌─────────────────────────┐
│  terraform.tfstate      │           │  Azure Blob Storage     │
│  sur votre machine      │  ──────▶  │  jean.tfstate           │
│  ❌ perdu si crash      │           │  ✅ partagé + verrouillé│
└─────────────────────────┘           └─────────────────────────┘
```

---

### Exercice 6.1 — Créer le storage pour le remote state

```bash
export OWNER="prenom-nom"
export RG_BACKEND="rg-tfstate-${OWNER}"
export SA_BACKEND="ststate${OWNER//-/}"

az group create --name "$RG_BACKEND" --location "francecentral"

az storage account create \
  --name           "$SA_BACKEND" \
  --resource-group "$RG_BACKEND" \
  --location       "francecentral" \
  --sku            Standard_LRS

az storage container create \
  --name         "tfstate" \
  --account-name "$SA_BACKEND"
```

---

### Exercice 6.2 — Configurer le backend

`terraform/backend.tf` est déjà préconfiguré pour recevoir les valeurs via `-backend-config`. Initialisez avec migration du state local :

```bash
terraform init \
  -backend-config="resource_group_name=rg-tfstate-${OWNER}" \
  -backend-config="storage_account_name=ststate${OWNER//-/}" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=${OWNER}.terraform.tfstate" \
  -migrate-state
```

<details>
<summary>💡 Correction</summary>

**Points clés :**
- `key` : nom du blob — chaque étudiant a un `key` différent → pas de conflit
- `-migrate-state` : déplace le state local vers Azure Blob Storage
- Après migration, supprimez `terraform.tfstate` local
- **Verrouillage** : un `apply` simultané depuis une autre machine échoue avec "state locked"

**Vérifier que le state est en remote :**
```bash
az storage blob list \
  --container-name "tfstate" \
  --account-name   "ststate${OWNER//-/}" \
  --output         table
```

</details>

---

## Étape 7 — Réseau avec le module network (1h)

> 🎯 **Pourquoi on fait ça ?**
> Vous avez créé VNet, subnets et NSG manuellement en CLI dans le TP Module 4. Ici, vous les décrivez dans `modules/network/main.tf`. L'avantage Terraform : si vous avez besoin du même réseau en staging et en production, vous appelez deux fois le même module avec des paramètres différents.

### Exercice 7.1 — Remplir `modules/network/main.tf`

Complétez les 4 TODO du module network :

1. VNet `vnet-${var.owner}-tf` avec espace `10.0.0.0/16`
2. `subnet-frontend` (10.0.1.0/24) et `subnet-backend` (10.0.2.0/24)
3. NSG avec les 3 règles : Allow-HTTP (100), Allow-HTTPS (110), Deny-All-Inbound (4000)
4. Association NSG → subnet-frontend

Documentation : [`azurerm_virtual_network`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network), [`azurerm_network_security_group`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)

<details>
<summary>💡 Correction</summary>

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "frontend" {
  name                 = "subnet-frontend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "subnet-backend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-frontend-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "frontend_nsg" {
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
```

**Dans `outputs.tf` :**
```hcl
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
output "subnet_frontend_id" {
  value = azurerm_subnet.frontend.id
}
```

**Différence CLI vs Terraform pour le NSG :**
En CLI, vous deviez désassocier le NSG du subnet avant de le supprimer. En Terraform, la ressource `azurerm_subnet_network_security_group_association` gère cela automatiquement — `terraform destroy` supprime l'association avant le NSG.

</details>

---

### Exercice 7.2 — Activer le module network

Décommentez `module "network"` dans `main.tf` et appliquez :

```bash
terraform init
terraform plan    # combien de ressources réseau ?
terraform apply
```

<details>
<summary>💡 Correction</summary>

Le plan doit afficher **5 to add** : VNet, 2 subnets, NSG, association NSG-subnet.

En CLI, vous avez créé ces ressources avec 7 commandes `az`. En Terraform : un `terraform apply`.

</details>

---

## Étape 8 — CI/CD avec GitHub Actions + OIDC (1h30)

> 🎯 **Pourquoi on fait ça ?**
> Le workflow `.github/workflows/terraform.yml` est déjà dans votre starter. Il fait un `plan` sur chaque PR et un `apply` automatique après le merge — sans jamais stocker de mot de passe.

### Concept — OIDC

```
Classique (à éviter)                  OIDC (recommandé)
ARM_CLIENT_SECRET = mot de passe  →   Token JWT GitHub (5 min, lié à votre repo)
❌ à stocker dans les secrets         ✅ pas de secret
❌ à renouveler tous les 90 jours     ✅ généré à chaque run
```

---

### Exercice 8.1 — Configurer OIDC

Si vous avez déjà un Service Principal depuis le TP CLI, ajoutez juste une federated credential supplémentaire :

```bash
APP_ID=$(az ad sp list --display-name "sp-github-<votre-username>" \
  --query "[0].appId" -o tsv)

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{
    \"name\": \"github-azure-infra-terraform\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:<votre-username>/azure-infra-terraform:ref:refs/heads/main\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"
```

**Secrets GitHub** (Settings → Secrets and variables → Actions de votre repo) :

| Secret | Valeur |
|--------|--------|
| `AZURE_CLIENT_ID` | App ID du Service Principal |
| `AZURE_TENANT_ID` | Tenant ID Azure AD |
| `AZURE_SUBSCRIPTION_ID` | ID de votre subscription |
| `AZURE_OWNER` | votre `prenom-nom` |
| `TF_BACKEND_RG` | `rg-tfstate-prenom-nom` |
| `TF_BACKEND_SA` | `ststateprenomnom` |

> ℹ️ Pas de `AZURE_CLIENT_SECRET` — c'est tout l'intérêt de l'OIDC.

<details>
<summary>💡 Vérifier la federated credential</summary>

```bash
az ad app federated-credential list --id "$APP_ID" \
  --query "[].{Nom:name, Subject:subject}" \
  --output table
```

Vous devez voir deux entrées : une pour `azure-infra-cli` et une pour `azure-infra-terraform`.

</details>

---

### Exercice 8.2 — Explorer `.github/workflows/terraform.yml`

Ouvrez le workflow et répondez :

1. Quand se déclenche-t-il en mode `plan` ?
2. Quand passe-t-il en mode `apply` ?
3. Comment le plan est-il partagé avec les reviewers ?
4. Comment `destroy` est-il déclenché ?

<details>
<summary>💡 Correction</summary>

**1.** Sur chaque Pull Request ciblant `main` qui touche `terraform/**`

**2.** Sur chaque push sur `main` (après merge de PR)

**3.** Le workflow commente la PR avec le texte du `terraform plan` via `actions/github-script`. Les reviewers voient exactement ce qui va changer **avant** d'approuver.

**4.** Uniquement via `workflow_dispatch` avec `action: destroy` — jamais automatiquement. Protection contre les destructions accidentelles.

</details>

---

### Exercice 8.3 — Déclencher un plan via Pull Request

Modifiez l'image du container, poussez, ouvrez une PR et observez le commentaire automatique.

1. Changez `nginx:latest` en `nginx:1.25` dans `modules/container/main.tf`
2. Committez et poussez
3. Ouvrez une PR vers `main`
4. Le plan doit commenter `-/+` sur le container (destroy + recreate)
5. Mergez — l'apply se déclenche automatiquement

---

## Étape 9 — tflint et pre-commit (45 min)

> 🎯 **Pourquoi on fait ça ?**
> `tflint` va plus loin que `terraform validate` : il détecte les variables non utilisées, les types incorrects pour Azure, les conventions de nommage. Associé à un hook pre-commit, il bloque le commit si le code ne passe pas.

### Installation

```bash
brew install tflint          # macOS
# Linux : curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
pip install pre-commit --break-system-packages
```

### Exercice 9.1 — Configurer tflint

Créez `terraform/.tflint.hcl` :

```hcl
plugin "azurerm" {
  enabled = true
  version = "0.26.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

rule "terraform_naming_convention"    { enabled = true }
rule "terraform_unused_declarations"  { enabled = true }
rule "terraform_documented_variables" { enabled = true }
rule "terraform_documented_outputs"   { enabled = true }
```

```bash
tflint --init
tflint --chdir=terraform/
```

### Exercice 9.2 — Hook pre-commit

```bash
pre-commit install
git add .
git commit -m "test: hooks tflint"
# → Le hook vérifie le format avant chaque commit
```

---

## Étape 10 — Exercice fil rouge final (45 min)

### Exercice 10.1 — PR finale

```bash
terraform fmt
terraform validate
tflint --chdir=terraform/

git add terraform/
git commit -m "feat(terraform): infrastructure AzureTech complète — réseau + remote state + CI/CD"
git push origin feat/terraform-resources
```

Vérifiez sur la PR que :
- [ ] Le `terraform plan` CI est vert
- [ ] Le plan affiche exactement les ressources attendues
- [ ] Pas de `*.tfstate` ni `.terraform/` commité
- [ ] Les 4 outputs (URLs) sont visibles dans la CI

### Exercice 10.2 — Revue croisée

En tant que reviewer, vérifiez :
- [ ] `variables.tf` des modules : toutes les variables ont une `description`
- [ ] `outputs.tf` : URLs App Service, Function App, Container, Storage exposées
- [ ] Tag `managed_by = "terraform"` sur toutes les ressources
- [ ] Pas de `ARM_CLIENT_SECRET` dans le workflow
- [ ] Remote state configuré (pas de `terraform.tfstate` dans le repo)

---

## BONUS — Workspaces Terraform

```bash
terraform workspace new staging
terraform workspace select staging
terraform plan   # state isolé par workspace
```

```hcl
resource "azurerm_linux_web_app" "app" {
  name = "app-${var.owner}-${terraform.workspace}-tf"
}
```

---

## Grille d'évaluation (20 pts)

| Critère | Points |
|---------|--------|
| `modules/storage/main.tf` complété (SA + 2 containers) | 2 |
| `modules/app-service/main.tf` complété (Python 3.11, HTTPS) | 2 |
| `modules/function-app/main.tf` complété (storage dédié) | 2 |
| `modules/container/main.tf` complété (nginx, IP publique) | 2 |
| `modules/network/main.tf` complété (VNet + NSG + association) | 2 |
| Modules activés dans `main.tf` avec les bons paramètres | 2 |
| Outputs racine (4 URLs) | 1 |
| Remote state configuré dans Azure Blob Storage | 2 |
| PR avec `terraform plan` commenté automatiquement (OIDC) | 2 |
| Pas de secret dans le code (`ARM_CLIENT_SECRET` absent) | 1 |
| PR mergée après revue croisée | 1 |
| BONUS — Workspaces staging/production | 1 |

---

> 💶 **Pensez à détruire vos ressources à la fin du TP :**
> ```bash
> terraform destroy
> # Le Resource Group est conservé — seules les ressources managed_by=terraform sont supprimées
> ```

---

*Formation DevSecOps Azure — Simplon*
