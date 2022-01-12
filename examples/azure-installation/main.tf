provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "ocean-controller" {
  source = "../.."

  # Credentials.
  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  # Configuration.
  cluster_identifier    = var.cluster_identifier
  acd_identifier        = var.acd_identifier
  aks_connector_enabled = true
}
