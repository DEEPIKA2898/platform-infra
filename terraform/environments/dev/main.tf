# ============================================================
# environments/dev/main.tf
# ⚠️  PARAMS TO UPDATE:
#   workspace_name → "dbx-dev-001" (change if you prefer)
#   max_workers    → reduce to 2 to save costs on free account
# ============================================================

locals {
  env = var.environment
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "platform-infra"
  }
}

data "azurerm_client_config" "current" {}

# ── Resource Group ───────────────────────────────────────────
resource "azurerm_resource_group" "workspace" {
  name     = "rg-databricks-${local.env}"
  location = var.location
  tags     = local.tags
}

# ── 1. Networking ────────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  name                = "dbx-${local.env}"
  resource_group_name = azurerm_resource_group.workspace.name
  location            = var.location
  vnet_address_space  = "10.20.0.0/16"
  public_subnet_cidr  = "10.20.1.0/24"
  private_subnet_cidr = "10.20.2.0/24"
  tags                = local.tags
}

# ── 2. Workspace ─────────────────────────────────────────────
module "workspace" {
  source = "../../modules/workspace"

  workspace_name       = "dbx-${local.env}-001" # ← UPDATE name if preferred
  resource_group_name  = azurerm_resource_group.workspace.name
  location             = var.location
  sku                  = "premium"
  vnet_id              = module.networking.vnet_id
  public_subnet_name   = module.networking.public_subnet_name
  private_subnet_name  = module.networking.private_subnet_name
  public_nsg_assoc_id  = module.networking.public_nsg_association_id
  private_nsg_assoc_id = module.networking.private_nsg_association_id
  tags                 = local.tags
  log_analytics_id     = ""
  depends_on           = [module.networking]
}

# ── 3. Unity Catalog ─────────────────────────────────────────
module "unity_catalog" {
  source = "../../modules/unity-catalog"

  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
  }

  region       = var.location
  workspace_id = module.workspace.workspace_id
  environment  = local.env
  catalog_name = local.env
  admin_group  = var.admin_group_name

  depends_on = [module.workspace]
}

# ── 4. Security ──────────────────────────────────────────────
module "security" {
  source = "../../modules/security"

  providers = {
    databricks.workspace = databricks.workspace
  }

  environment         = local.env
  resource_group_name = azurerm_resource_group.workspace.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags
  key_vault_sku       = "standard"
  depends_on          = [module.workspace]
}

# ── 5. Compute ───────────────────────────────────────────────
module "compute" {
  source = "../../modules/compute"

  providers = {
    databricks.workspace = databricks.workspace
  }

  environment   = local.env
  max_workers   = 2 # ← Keep at 2 for demo (cost saving)
  min_workers   = 1
  node_type     = "Standard_D4s_v3"
  tags          = local.tags
  spark_version = "14.3.x-scala2.12"

  depends_on = [module.workspace]
}
