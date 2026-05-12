# ============================================================
# modules/workspace/main.tf
# Azure Databricks workspace with VNet injection
# ============================================================

resource "azurerm_databricks_workspace" "this" {
  name                        = var.workspace_name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku                         = var.sku
  managed_resource_group_name = "${var.workspace_name}-managed"

  custom_parameters {
    no_public_ip        = true
    virtual_network_id  = var.vnet_id
    public_subnet_name  = var.public_subnet_name
    private_subnet_name = var.private_subnet_name

    public_subnet_network_security_group_association_id  = var.public_nsg_assoc_id
    private_subnet_network_security_group_association_id = var.private_nsg_assoc_id
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_diagnostic_setting" "workspace" {
  count                      = var.log_analytics_id != "" ? 1 : 0
  name                       = "diag-${var.workspace_name}"
  target_resource_id         = azurerm_databricks_workspace.this.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "dbfs"
  }

  enabled_log {
    category = "clusters"
  }

  enabled_log {
    category = "jobs"
  }

  enabled_log {
    category = "notebook"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}