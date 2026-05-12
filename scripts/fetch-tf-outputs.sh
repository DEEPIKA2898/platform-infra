#!/bin/bash
# ============================================================
# fetch-tf-outputs.sh
# Used by the DABs pipeline to read Terraform outputs from
# Key Vault and export them as environment variables
#
# Usage: source ./scripts/fetch-tf-outputs.sh <env> <kv-name>
# Example: source ./scripts/fetch-tf-outputs.sh dev kv-platform-dev-001
# ============================================================
set -euo pipefail

ENV=${1:-dev}
KV_NAME=${2:-"kv-platform-${ENV}-001"}

echo ">> Fetching Terraform outputs from Key Vault: $KV_NAME"

TF_JSON=$(az keyvault secret show \
  --vault-name "$KV_NAME" \
  --name "tf-outputs" \
  --query "value" -o tsv)

export DBX_WORKSPACE_URL=$(echo "$TF_JSON"    | jq -r '.workspace_url.value')
export DBX_CLUSTER_ID=$(echo "$TF_JSON"       | jq -r '.cluster_id.value')
export DBX_CATALOG_NAME=$(echo "$TF_JSON"     | jq -r '.catalog_name.value')
export DBX_SECRET_SCOPE=$(echo "$TF_JSON"     | jq -r '.secret_scope_name.value')
export DBX_SP_APP_ID=$(echo "$TF_JSON"        | jq -r '.cicd_sp_app_id.value')
export DBX_INSTANCE_POOL=$(echo "$TF_JSON"    | jq -r '.instance_pool_id.value')
export DBX_CLUSTER_POLICY=$(echo "$TF_JSON"   | jq -r '.cluster_policy_id.value')
export DBX_BRONZE_SCHEMA=$(echo "$TF_JSON"    | jq -r '.bronze_schema.value')
export DBX_SILVER_SCHEMA=$(echo "$TF_JSON"    | jq -r '.silver_schema.value')
export DBX_GOLD_SCHEMA=$(echo "$TF_JSON"      | jq -r '.gold_schema.value')

echo ">> Outputs loaded:"
echo "   Workspace : $DBX_WORKSPACE_URL"
echo "   Cluster   : $DBX_CLUSTER_ID"
echo "   Catalog   : $DBX_CATALOG_NAME"
echo "   Scope     : $DBX_SECRET_SCOPE"
