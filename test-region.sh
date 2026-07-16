#!/bin/bash
REGIONS=("francecentral" "northeurope" "uksouth" "swedencentral" "polandcentral" "eastus" "centralus" "westus2")

for region in "${REGIONS[@]}"; do
  echo "Test sur $region..."
  az appservice plan create \
    --name "test-plan-$region" \
    --resource-group rg-malik-cherfi \
    --location "$region" \
    --sku B1 \
    --is-linux \
    && echo "✅ SUCCÈS sur $region" && break \
    || echo "❌ Échec sur $region, essai suivant..."
done

az appservice plan delete --name "test-plan-swedencentral" --resource-group rg-malik-cherfi --yes