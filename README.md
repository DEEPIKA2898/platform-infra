# platform-infra

Databricks platform infrastructure — Terraform + GitHub Actions.

## Structure
```
terraform/
  backend/          # Bootstrap remote state (run once manually)
  modules/
    workspace/      # Databricks workspace + VNet
    unity-catalog/  # Metastore + catalogs + schemas
    networking/     # VNet, subnets, NSG
    security/       # Key Vault, SPs, secret scopes, cluster policy
    compute/        # Shared cluster + instance pool
  environments/
    dev/
    staging/
    prod/
scripts/
  bootstrap.sh          # One-time backend bootstrap
  verify-deployment.sh  # Post-deploy verification
.github/workflows/
  infra.yml        # Main CI/CD pipeline
  drift-detect.yml # Nightly drift detection
  destroy.yml      # Manual destroy (dev only)
```

## Quick Start
1. Run `scripts/bootstrap.sh` to create remote state backend
2. Add GitHub secrets (see docs)
3. Push to a feature branch → opens PR with plan
4. Merge to main → auto-deploys dev, gates on staging/prod


