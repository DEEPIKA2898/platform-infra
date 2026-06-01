# ============================================================
# PARAMS.md — Parameters You Must Update Before Running
# ============================================================
# Update every value marked with ← UPDATE in this file
# and in the corresponding Terraform/workflow files.
# ============================================================

## 1. Remote State Backend
# File: terraform/environments/dev/versions.tf

resource_group_name  = "rg-platform-tfstate"        # ← UPDATE if you used a different name
storage_account_name = "stplatformtfstate001"        # ← UPDATE to YOUR storage account name
container_name       = "tfstate"                     # ← UPDATE if you used a different name

## 2. GitHub Secrets (Settings → Secrets → Actions)
ARM_CLIENT_ID        = ""   # ← UPDATE — Service Principal Application (client) ID
ARM_CLIENT_SECRET    = ""   # ← UPDATE — Service Principal client secret value
ARM_TENANT_ID        = ""   # ← UPDATE — Azure Directory (tenant) ID
ARM_SUBSCRIPTION_ID  = ""   # ← UPDATE — Azure Subscription ID
DATABRICKS_ACCOUNT_ID = ""  # ← UPDATE — UUID from accounts.azuredatabricks.net

## 3. GitHub Environment Variables (Settings → Environments)
# dev environment:
KV_NAME_DEV          = "kv-platform-dev-001"         # ← UPDATE if you want a different name

## 4. Terraform Variables
# File: terraform/environments/dev/terraform.tfvars
location             = "swedencentral"               # ← UPDATE if using a different region
admin_group_name     = "platform-admins"             # ← UPDATE to your Databricks admin group


## 6. Optional — Workspace Name
# File: terraform/environments/dev/main.tf
workspace_name       = "dbx-dev-001"                 # ← UPDATE if you want a different name

## ============================================================
## WHERE TO FIND EACH VALUE
## ============================================================
##
## ARM_CLIENT_ID      → Azure Portal → Microsoft Entra ID
##                      → App registrations → your SP
##                      → Application (client) ID
##
## ARM_CLIENT_SECRET  → Azure Portal → Microsoft Entra ID
##                      → App registrations → your SP
##                      → Certificates & secrets → Value
##
## ARM_TENANT_ID      → Azure Portal → Microsoft Entra ID
##                      → Overview → Directory (tenant) ID
##
## ARM_SUBSCRIPTION_ID → Azure Portal → Subscriptions
##                       → Subscription ID
##
## DATABRICKS_ACCOUNT_ID → accounts.azuredatabricks.net
##                          → Top right profile → Account ID
##
## Storage account name → Azure Portal → Storage Accounts
##                         → the one you created manually
##
