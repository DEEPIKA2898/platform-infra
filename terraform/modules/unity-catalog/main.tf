terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.account, databricks.workspace]
    }
  }
}

# Use existing metastore — don't create a new one
data "databricks_current_metastore" "this" {
  provider = databricks.workspace
}

# Environment catalog
resource "databricks_catalog" "this" {
  provider     = databricks.workspace
  name         = var.catalog_name
  metastore_id = data.databricks_current_metastore.this.id
  comment      = "Main catalog for ${var.environment} environment"
}

# Bronze schema
resource "databricks_schema" "bronze" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "bronze"
  comment      = "Raw ingested data — append-only"
}

# Silver schema
resource "databricks_schema" "silver" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "silver"
  comment      = "Cleaned and conformed data"
}

# Gold schema
resource "databricks_schema" "gold" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "gold"
  comment      = "Aggregated business-ready metrics"
}