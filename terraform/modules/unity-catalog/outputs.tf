output "catalog_name" { value = databricks_catalog.this.name }
output "bronze_schema" { value = "${databricks_catalog.this.name}.${databricks_schema.bronze.name}" }
output "silver_schema" { value = "${databricks_catalog.this.name}.${databricks_schema.silver.name}" }
output "gold_schema" { value = "${databricks_catalog.this.name}.${databricks_schema.gold.name}" }
