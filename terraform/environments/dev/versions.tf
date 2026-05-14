# ============================================================
# environments/dev/versions.tf
# ⚠️  UPDATE: storage_account_name → your actual storage account name
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
    resource_group_name  = "rg-platform-tfstate"  # ← UPDATE if different
    storage_account_name = "stplatformtfstate012" # ← UPDATE to your storage account name
    container_name       = "tfstate"              # ← UPDATE if different
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

# Databricks account-level provider (for Unity Catalog metastore)
provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

# Databricks workspace-level provider (populated after workspace is created)
provider "databricks" {
  alias                       = "workspace"
  host                        = module.workspace.workspace_url
  azure_workspace_resource_id = module.workspace.workspace_resource_id
}
