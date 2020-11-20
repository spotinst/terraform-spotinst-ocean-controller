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

variable "module_depends_on" {
  type        = list
  description = "List of modules or resources this module depends on"
  default     = []
}

variable "create_controller" {
  type        = bool
  description = "Controls whether Ocean Controller should be created (it affects all resources)"
  default     = true
}

variable "image_pull_secrets" {
  type        = list(string)
  description = "List of docker image pull secrets"
  default     = []
}
