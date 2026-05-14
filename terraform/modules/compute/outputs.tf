output "shared_cluster_id" { value = databricks_cluster.shared.id }
output "instance_pool_id" { value = databricks_instance_pool.job_pool.id }
output "shared_cluster_url" {
  value = "${var.environment} — use cluster ID: ${databricks_cluster.shared.id}"
}
