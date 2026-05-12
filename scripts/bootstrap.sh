#!/bin/bash
# ============================================================
# bootstrap.sh — Run ONCE to create the Terraform remote state
# backend. Never manage this with Terraform itself.
# ============================================================
set -euo pipefail

# ── Configuration ────────────────────────────────────────────
RESOURCE_GROUP="rg-platform-tfstate"
LOCATION="westeurope"
STORAGE_ACCOUNT="stplatformtfstate001"   # Must be globally unique
CONTAINER="tfstate"

echo "================================================"
echo " Bootstrapping Terraform Remote State Backend"
echo "================================================"

# Login check
echo ">> Checking Azure login..."
az account show > /dev/null 2>&1 || { echo "ERROR: Run 'az login' first"; exit 1; }

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo ">> Using subscription: $SUBSCRIPTION_ID"

# Resource group
echo ">> Creating resource group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# Storage account
echo ">> Creating storage account: $STORAGE_ACCOUNT"
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_GRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none

# Enable versioning + soft delete
echo ">> Enabling versioning and soft-delete..."
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 30 \
  --output none

# Container
echo ">> Creating blob container: $CONTAINER"
az storage container create \
  --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output none

# RBAC for Terraform SP
if [ -n "${TF_SP_CLIENT_ID:-}" ]; then
  echo ">> Granting Storage Blob Data Contributor to SP..."
  STORAGE_ID=$(az storage account show \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query id -o tsv)

  az role assignment create \
    --assignee "$TF_SP_CLIENT_ID" \
    --role "Storage Blob Data Contributor" \
    --scope "$STORAGE_ID" \
    --output none
  echo ">> RBAC assigned"
else
  echo ">> Skipping RBAC (set TF_SP_CLIENT_ID env var to assign automatically)"
fi

echo ""
echo "================================================"
echo " Backend bootstrap complete!"
echo "================================================"
echo ""
echo "Add this backend block to your versions.tf files:"
echo ""
echo '  backend "azurerm" {'
echo "    resource_group_name  = \"$RESOURCE_GROUP\""
echo "    storage_account_name = \"$STORAGE_ACCOUNT\""
echo "    container_name       = \"$CONTAINER\""
echo '    key                  = "<env>/terraform.tfstate"'
echo '  }'
