# ============================================================
# modules/compute/main.tf
# Shared interactive cluster + instance pool
# ============================================================

terraform {
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks.workspace]
    }
  }
}

# ── Instance Pool ────────────────────────────────────────────
resource "databricks_instance_pool" "job_pool" {
  provider                              = databricks.workspace
  instance_pool_name                    = "job-pool-${var.environment}"
  min_idle_instances                    = 0
  max_capacity                          = 20
  idle_instance_autotermination_minutes = 15
  node_type_id                          = var.node_type

  azure_attributes {
    availability       = "SPOT_AZURE"
    spot_bid_max_price = 100
  }

}

# ── Shared Interactive Cluster ───────────────────────────────
resource "databricks_cluster" "shared" {
  provider                = databricks.workspace
  cluster_name            = "shared-${var.environment}"
  spark_version           = var.spark_version
  node_type_id            = var.node_type
  autotermination_minutes = 30
  data_security_mode      = "SINGLE_USER"

  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }

  azure_attributes {
    availability       = "SPOT_WITH_FALLBACK_AZURE"
    first_on_demand    = 1
    spot_bid_max_price = 100
  }

  spark_conf = {
    "spark.databricks.delta.preview.enabled" = "true"
    "spark.sql.shuffle.partitions"           = "auto"
  }

  library {
    pypi {
      package = "delta-spark==3.0.0"
    }
  }

  timeouts {
    create = "30m"
  }
}
