# ============================================================
# environments/dev/outputs.tf
# These are written to Key Vault and consumed by DABs pipeline
# ============================================================

output "workspace_url" {
  description = "Databricks workspace URL"
  value       = module.workspace.workspace_url
}

output "workspace_resource_id" {
  description = "Azure resource ID of the workspace"
  value       = module.workspace.workspace_resource_id
}

output "cluster_id" {
  description = "Shared cluster ID — used by DABs bundles"
  value       = module.compute.shared_cluster_id
}

output "instance_pool_id" {
  description = "Instance pool ID — used by job clusters"
  value       = module.compute.instance_pool_id
}

output "catalog_name" {
  description = "Unity Catalog name"
  value       = module.unity_catalog.catalog_name
}

output "bronze_schema" {
  description = "Fully qualified bronze schema (catalog.schema)"
  value       = module.unity_catalog.bronze_schema
}

output "silver_schema" {
  description = "Fully qualified silver schema"
  value       = module.unity_catalog.silver_schema
}

output "gold_schema" {
  description = "Fully qualified gold schema"
  value       = module.unity_catalog.gold_schema
}

output "secret_scope_name" {
  description = "Databricks secret scope name (backed by Key Vault)"
  value       = module.security.secret_scope_name
}

output "cicd_sp_app_id" {
  description = "Service Principal app ID for CI/CD"
  value       = module.security.cicd_sp_app_id
}

output "cluster_policy_id" {
  description = "Cluster policy ID for job clusters"
  value       = module.security.cluster_policy_id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.security.key_vault_uri
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.security.key_vault_name
}
