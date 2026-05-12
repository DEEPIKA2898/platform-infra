output "workspace_url" {
  description = "Full HTTPS URL of the workspace"
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}"
}

output "workspace_resource_id" {
  description = "Azure resource ID of the workspace"
  value       = azurerm_databricks_workspace.this.id
}

output "workspace_id" {
  description = "Numeric Databricks workspace ID (for Unity Catalog assignment)"
  value       = azurerm_databricks_workspace.this.workspace_id
}
