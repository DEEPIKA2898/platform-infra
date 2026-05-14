# ============================================================
# environments/staging/terraform.tfvars
# ⚠️  Safe to commit — no secrets here
# ⚠️  PARAMS TO UPDATE:
#   location         → change if not using Sweden Central
#   admin_group_name → your Databricks admin group name
# ============================================================

environment      = "staging"
location         = "swedencentral"   # ← UPDATE if using different region (e.g. westeurope)
admin_group_name = "platform-admins" # ← UPDATE to your Databricks admin group name

# subscription_id and databricks_account_id are passed
# via GitHub Actions secrets — never hardcode here
