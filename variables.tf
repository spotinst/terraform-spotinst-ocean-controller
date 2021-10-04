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

variable "create_controller" {
  type        = bool
  description = "Controls whether the Ocean Controller should be deployed (it affects all resources)"
  default     = true
}

variable "controller_image" {
  type        = string
  description = "Set the Docker image name for the Ocean Controller that should be deployed"
  default     = "gcr.io/spotinst-artifacts/kubernetes-cluster-controller"
}

variable "controller_version" {
  type        = string
  description = "Set the Docker version for the Ocean Controller that should be deployed"
  default     = "1.0.78"
}

variable "image_pull_policy" {
  type        = string
  description = "Image pull policy (one of: Always, Never, IfNotPresent)"
  default     = "Always"
}

variable "base_url" {
  type        = string
  description = "Base URL to be used by the HTTP client"
  default     = ""
}

variable "proxy_url" {
  type        = string
  description = "Proxy server URL to communicate through"
  default     = ""
}

variable "enable_csr_approval" {
  type        = bool
  description = "Enable the CSR approval feature"
  default     = false
}

variable "disable_auto_update" {
  type        = bool
  description = "Disable the auto-update feature"
  default     = false
}

variable "image_pull_secrets" {
  type        = list(string)
  description = "List of references to secrets in the same namespace to use for pulling the image"
  default     = []
}

variable "resources_limits" {
  type        = map(any)
  description = "Definition of the maximum amount of compute resources allowed"
  default     = null
  //  default = {
  //    cpu    = "0.5"
  //    memory = "512Mi"
  //  }
}

variable "resources_requests" {
  type        = map(any)
  description = "Definition of the minimum amount of compute resources required"
  default     = null
  //  default = {
  //    cpu    = "0.5"
  //    memory = "512Mi"
  //  }
}

variable "tolerations" {
  type        = list(any)
  description = "List of additional `toleration` objects, see: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod#toleration"
  default = [
    {
      key                = "node.kubernetes.io/not-ready"
      effect             = "NoExecute"
      operator           = "Exists"
      toleration_seconds = 150
    },
    {
      key                = "node.kubernetes.io/unreachable"
      effect             = "NoExecute"
      operator           = "Exists"
      toleration_seconds = 150
    },
  ]
}

variable "aks_connector_enabled" {
  type        = bool
  description = "Controls whether the Ocean AKS Connector should be deployed (requires a valid `acd_identifier`)"
  default     = true
}

variable "aks_connector_image" {
  type        = string
  description = "Set the Docker image name for the Ocean AKS Connector that should be deployed"
  default     = "spotinst/ocean-aks-connector"
}

variable "aks_connector_version" {
  type        = string
  description = "Set the Docker version for the Ocean AKS Connector that should be deployed"
  default     = "1.0.8"
}

variable "acd_identifier" {
  type        = string
  description = "A unique identifier used by the Ocean AKS Connector when importing an AKS cluster"
  default     = null
}
