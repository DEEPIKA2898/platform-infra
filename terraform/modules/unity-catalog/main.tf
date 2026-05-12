# ============================================================
# modules/unity-catalog/main.tf
# Unity Catalog — metastore, catalog, medallion schemas
# ============================================================

terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.account, databricks.workspace]
    }
  }
}

# Metastore — one per Azure region, shared across workspaces
resource "databricks_metastore" "this" {
  provider      = databricks.account
  name          = "metastore-${var.region}-${var.environment}"
  region        = var.region
  owner         = var.admin_group
  force_destroy = false
}

# Assign metastore to this workspace
resource "databricks_metastore_assignment" "this" {
  provider             = databricks.workspace
  metastore_id         = databricks_metastore.this.id
  workspace_id         = var.workspace_id
  default_catalog_name = var.catalog_name
}

# Environment catalog
resource "databricks_catalog" "this" {
  provider     = databricks.workspace
  name         = var.catalog_name
  metastore_id = databricks_metastore.this.id
  comment      = "Main catalog for ${var.environment} environment"

  depends_on = [databricks_metastore_assignment.this]
}

# Bronze schema — raw ingested data
resource "databricks_schema" "bronze" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "bronze"
  comment      = "Raw ingested data — append-only, no transformations"
}

# Silver schema — cleaned and conformed
resource "databricks_schema" "silver" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "silver"
  comment      = "Cleaned, validated, and conformed data"
}

# Gold schema — aggregated business metrics
resource "databricks_schema" "gold" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "gold"
  comment      = "Aggregated business-ready metrics and features"
}
