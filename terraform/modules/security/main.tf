# ============================================================
# modules/security/main.tf
# Key Vault, Service Principals, Secret Scopes, Cluster Policy
# ============================================================

terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

data "azurerm_client_config" "current" {}

# ── Key Vault ────────────────────────────────────────────────
resource "azurerm_key_vault" "this" {
  name                       = "kv-dbx-${var.environment}-001"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.key_vault_sku
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]
  }

  tags = var.tags
}

# ── CI/CD Service Principal ──────────────────────────────────
resource "databricks_service_principal" "cicd" {
  provider     = databricks.workspace
  display_name = "sp-dbx-cicd-${var.environment}"
  active       = true
}

resource "databricks_entitlements" "cicd" {
  provider              = databricks.workspace
  service_principal_id  = databricks_service_principal.cicd.id
  allow_cluster_create  = true
  databricks_sql_access = true
  workspace_access      = true
}

# ── Secret Scope backed by Key Vault ────────────────────────
resource "databricks_secret_scope" "kv" {
  provider = databricks.workspace
  name     = "kv-${var.environment}"

  keyvault_metadata {
    resource_id = azurerm_key_vault.this.id
    dns_name    = azurerm_key_vault.this.vault_uri
  }
}

# ── Cluster Policy ───────────────────────────────────────────
resource "databricks_cluster_policy" "jobs" {
  provider = databricks.workspace
  name     = "job-cluster-policy-${var.environment}"

  definition = jsonencode({
    "spark_version" = {
      type  = "fixed"
      value = "14.3.x-scala2.12"
    }
    "node_type_id" = {
      type   = "allowlist"
      values = ["Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2"]
    }
    "autoscale.min_workers" = {
      type     = "range"
      minValue = 1
      maxValue = 2
    }
    "autoscale.max_workers" = {
      type     = "range"
      minValue = 2
      maxValue = 8
    }
    "autotermination_minutes" = {
      type  = "fixed"
      value = "30"
    }
  })
}
