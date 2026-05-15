# ============================================================
# environments/dev/versions.tf
# ============================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-platform-tfstate"
    storage_account_name = "stplatformtfstate012" # ← your storage account
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

# ── Databricks ACCOUNT-level provider ───────────────────────
# Used for Unity Catalog metastore (account admin level)
# Needs Azure SP credentials to authenticate at account level
provider "databricks" {
  alias               = "account"
  host                = "https://accounts.azuredatabricks.net"
  account_id          = var.databricks_account_id
  azure_tenant_id     = var.tenant_id     # ← moved here from workspace
  azure_client_id     = var.client_id     # ← moved here from workspace
  azure_client_secret = var.client_secret # ← moved here from workspace
}

# ── Databricks WORKSPACE-level provider ─────────────────────
# Used for everything inside the workspace (clusters, schemas etc)
# Authenticates automatically via Azure resource ID — no SP creds needed here
provider "databricks" {
  alias                       = "workspace"
  host                        = module.workspace.workspace_url
  azure_workspace_resource_id = module.workspace.workspace_resource_id
}