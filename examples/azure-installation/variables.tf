variable "spotinst_token" {
  type        = string
  description = "Spot Personal Access token"
}

variable "spotinst_account" {
  type        = string
  description = "Spot account ID"
}

variable "cluster_identifier" {
  type        = string
  description = "Cluster identifier"
}

variable "acd_identifier" {
  type        = string
  description = "A unique identifier used by the Ocean AKS Connector when importing an AKS cluster"
}
