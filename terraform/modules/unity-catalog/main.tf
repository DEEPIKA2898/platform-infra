terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.account, databricks.workspace]
    }
  }
}

data "databricks_current_metastore" "this" {
  provider = databricks.workspace
}

resource "databricks_catalog" "this" {
  provider     = databricks.workspace
  name         = var.catalog_name
  metastore_id = data.databricks_current_metastore.this.id
  comment      = "Main catalog for ${var.environment} environment"
  storage_root = "abfss://unity-catalog-storage@dbstoragefqoceyt7bjfi2.dfs.core.windows.net/7405617437550189"
}

resource "databricks_schema" "bronze" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "bronze"
  comment      = "Raw ingested data — append-only"
}

resource "databricks_schema" "silver" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "silver"
  comment      = "Cleaned and conformed data"
}

resource "databricks_schema" "gold" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.this.name
  name         = "gold"
  comment      = "Aggregated business-ready metrics"
}