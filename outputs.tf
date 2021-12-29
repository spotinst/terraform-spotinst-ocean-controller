output "acd_identifier" {
  description = "Unique identifier used by the Ocean AKS Connector when importing an AKS cluster"
  value       = var.acd_identifier

  depends_on = [
    kubernetes_job.this
  ]
}

output "cluster_identifier" {
  description = "Cluster identifier"
  value       = kubernetes_config_map.this[0].data["spotinst.cluster-identifier"]

  depends_on = [
    kubernetes_deployment.this
  ]
}

output "spotinst_account" {
  description = "Spot account ID"
  value       = kubernetes_secret.this[0].metadata[0].name
}
