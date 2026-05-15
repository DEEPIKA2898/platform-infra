# ============================================================
# environments/dev/variables.tf
# ============================================================

variable "subscription_id" {
  description = "Azure subscription ID — injected by GitHub Actions"
  type        = string
}

variable "databricks_account_id" {
  description = "Databricks account UUID (accounts.azuredatabricks.net)"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "admin_group_name" {
  description = "Databricks admin group display name"
  type        = string
  default     = "platform-admins"
}

variable "node_type" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}