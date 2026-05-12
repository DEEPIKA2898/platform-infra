#!/bin/bash
# ============================================================
# verify-deployment.sh — Post-deploy sanity checks
# Usage: ./scripts/verify-deployment.sh dev
# ============================================================
set -euo pipefail

ENV=${1:-dev}
echo "================================================"
echo " Verifying deployment: $ENV"
echo "================================================"

# Read outputs from Terraform
cd "terraform/environments/$ENV"
terraform init -reconfigure > /dev/null 2>&1

echo ">> Reading Terraform outputs..."
WORKSPACE_URL=$(terraform output -raw workspace_url 2>/dev/null || echo "NOT FOUND")
CLUSTER_ID=$(terraform output -raw cluster_id 2>/dev/null || echo "NOT FOUND")
CATALOG=$(terraform output -raw catalog_name 2>/dev/null || echo "NOT FOUND")
KV_URI=$(terraform output -raw key_vault_uri 2>/dev/null || echo "NOT FOUND")

echo ""
echo "── Outputs ──────────────────────────────────────"
echo "  Workspace URL : $WORKSPACE_URL"
echo "  Cluster ID    : $CLUSTER_ID"
echo "  Catalog       : $CATALOG"
echo "  Key Vault URI : $KV_URI"

# Check state file
echo ""
echo ">> Checking remote state..."
az storage blob list \
  --container-name tfstate \
  --account-name stplatformtfstate001 \
  --auth-mode login \
  --query "[?contains(name,'$ENV')].[name,properties.lastModified]" \
  --output table 2>/dev/null || echo "  (Could not list blobs — check permissions)"

echo ""
echo "================================================"
echo " Verification complete for: $ENV"
echo "================================================"
