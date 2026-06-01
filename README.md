# platform-infra

> End-to-end Databricks platform infrastructure — automated with Terraform and GitHub Actions.

## Overview

This repository manages all Azure and Databricks infrastructure as code. Every resource is provisioned, updated, and destroyed through a CI/CD pipeline — nothing is created manually.

```
GitHub Actions pipeline
        ↓
Terraform modules
        ↓
Azure resources + Databricks workspace
        ↓
Outputs exported to Key Vault
        ↓
Consumed by data-pipelines repo
```

---

## Architecture

```
Azure Subscription (pay-as-you-go)
└── rg-databricks-dev
    ├── Networking module
    │   ├── Virtual Network (10.20.0.0/16)
    │   ├── Public subnet  (10.20.1.0/24)
    │   ├── Private subnet (10.20.2.0/24)
    │   └── Network Security Group
    ├── Workspace module
    │   ├── Azure Databricks (Premium SKU)
    │   ├── VNet injection (no public IP)
    │   └── Managed resource group
    ├── Unity Catalog module
    │   ├── Metastore (swedencentral)
    │   ├── Catalog: dev
    │   └── Schemas: bronze · silver · gold
    ├── Security module
    │   ├── Azure Key Vault
    │   ├── CI/CD Service Principal
    │   ├── Secret scope (KV-backed)
    │   └── Cluster policy
    └── Compute module
        ├── Shared interactive cluster
        └── Instance pool (spot VMs)
```

---

## Repository Structure

```
platform-infra/
├── terraform/
│   ├── modules/
│   │   ├── networking/       # VNet, subnets, NSG
│   │   ├── workspace/        # Databricks workspace
│   │   ├── unity-catalog/    # Metastore, catalog, schemas
│   │   ├── security/         # Key Vault, SP, secret scope
│   │   └── compute/          # Cluster, instance pool
│   └── environments/
│       ├── dev/              # Dev environment config
│       ├── staging/          # Staging environment config
│       └── prod/             # Prod environment config
├── scripts/
│   ├── bootstrap.sh          # One-time backend setup (already done)
│   ├── fetch-tf-outputs.sh   # Read Key Vault outputs locally
│   └── verify-deployment.sh  # Post-deploy verification
├── .github/
│   └── workflows/
│       ├── infra.yml         # Main CI/CD pipeline
│       ├── drift-detect.yml  # Nightly drift detection
│       └── destroy.yml       # Manual destroy (dev only)
└── PARAMS.md                 # Parameters to update
```

---

## Pipeline Flow

```
Push to branch → Open PR
        ↓
✅ Validate (terraform fmt + validate)
        ↓
✅ Security Scan (tfsec + checkov)
        ↓
✅ Plan / dev (terraform plan — posts summary on PR)
        ↓
Merge PR to main
        ↓
✅ Apply / dev (auto — no approval needed)
        ↓
✅ Export outputs to Key Vault
        ↓
🔐 Apply / staging (manual approval)
        ↓
🔐 Apply / production (2 approvers)
```

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Terraform | >= 1.6.0 | https://developer.hashicorp.com/terraform/install |
| Azure CLI | latest | https://learn.microsoft.com/cli/azure/install-azure-cli |
| Databricks CLI | >= 0.210 | https://docs.databricks.com/dev-tools/cli/install.html |
| Git | any | https://git-scm.com |

---

## GitHub Secrets Required

Add these in **Settings → Secrets → Actions**:

| Secret | Description | Where to find |
|---|---|---|
| `ARM_CLIENT_ID` | Service Principal client ID | Azure Portal → Microsoft Entra ID → App registrations |
| `ARM_CLIENT_SECRET` | Service Principal secret | Azure Portal → App registrations → Certificates & secrets |
| `ARM_TENANT_ID` | Azure tenant ID | Azure Portal → Microsoft Entra ID → Overview |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID | Azure Portal → Subscriptions |
| `DATABRICKS_ACCOUNT_ID` | Databricks account UUID | accounts.azuredatabricks.net → profile icon |

### GitHub Environment Variables

Add under **Settings → Environments → dev**:

| Variable | Value |
|---|---|
| `KV_NAME_DEV` | Name of your Key Vault (e.g. `kv-platform-dev-001`) |

---

## Remote State Backend

Terraform state is stored in Azure Blob Storage. This was created manually in Azure Portal directly.

```
Resource group:   rg-platform-tfstate
Storage account:  stplatformtfstate012   ← your actual name
Container:        tfstate
State keys:
  dev/terraform.tfstate

```

---

## Local Development

```bash
# Login to Azure
az login

# Navigate to dev environment
cd terraform/environments/dev

# Initialise (connects to remote backend)
terraform init

# Plan — preview changes
terraform plan \
  -var="subscription_id=$(az account show --query id -o tsv)" \
  -var="databricks_account_id=YOUR_ACCOUNT_ID" \
  -var="tenant_id=YOUR_TENANT_ID" \
  -var="client_id=YOUR_CLIENT_ID" \
  -var="client_secret=YOUR_CLIENT_SECRET"


---

## Deployed Resources

After a successful deployment, verify these exist:

```bash
# List all resources in dev resource group
az resource list --resource-group rg-databricks-dev --output table

# Get workspace URL
cd terraform/environments/dev
terraform output workspace_url

# Check Key Vault outputs
az keyvault secret show \
  --vault-name "$(terraform output -raw key_vault_name)" \
  --name "tf-outputs" \
  --query "value" -o tsv | jq .
```

---

## Destroy (after demo)

```bash
cd terraform/environments/dev

terraform destroy \
  -var="subscription_id=$(az account show --query id -o tsv)" \
  -var="databricks_account_id=YOUR_ACCOUNT_ID" \
  -var="tenant_id=YOUR_TENANT_ID" \
  -var="client_id=YOUR_CLIENT_ID" \
  -var="client_secret=YOUR_CLIENT_SECRET"
```



---

## Cost Estimate (dev environment)

| Resource | Cost |
|---|---|
| Databricks cluster (spot, idle) | ~$0.40/hr when running |
| Key Vault | ~$0.03/month |
| Storage account | ~$0.01/month |
| VNet / NSG | Free |
| **Cluster autotermination** | **30 min idle → auto shutdown** |

**Destroy after demo to stop all costs.**

---

## Troubleshooting

| Error | Fix |
|---|---|
| `Backend not found` | Check storage account name in `versions.tf` |
| `Metastore limit reached` | Only 1 metastore per region — use existing one |
| `VM size not available` | Run `az vm list-skus --location swedencentral` to find available sizes |
| `Account admin required` | Add SP as Account Admin in accounts.azuredatabricks.net |
| `Stale plan` | Pipeline reruns plan + apply together — no artifact reuse |

---


