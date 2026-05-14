output "key_vault_id" { value = azurerm_key_vault.this.id }
output "key_vault_uri" { value = azurerm_key_vault.this.vault_uri }
output "key_vault_name" { value = azurerm_key_vault.this.name }
output "cicd_sp_app_id" { value = databricks_service_principal.cicd.application_id }
output "secret_scope_name" { value = databricks_secret_scope.kv.name }
output "cluster_policy_id" { value = databricks_cluster_policy.jobs.id }
