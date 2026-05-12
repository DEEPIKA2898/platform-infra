# ============================================================
# backend/main.tf
# Documents the remote state storage — managed manually,
# NOT by Terraform. See scripts/bootstrap.sh to create it.
# ============================================================

# This file is documentation-only.
# The actual storage is created by scripts/bootstrap.sh.
#
# Backend config used in every environment:
#
#   backend "azurerm" {
#     resource_group_name  = "rg-platform-tfstate"
#     storage_account_name = "stplatformtfstate001"
#     container_name       = "tfstate"
#     key                  = "<env>/terraform.tfstate"
#   }
#
# State file layout:
#   tfstate/dev/terraform.tfstate
#   tfstate/staging/terraform.tfstate
#   tfstate/prod/terraform.tfstate
