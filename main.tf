resource "null_resource" "module_depends_on" {
  count = var.create_controller && length(var.module_depends_on) > 0 ? 1 : 0

  triggers = {
    value = length(var.module_depends_on)
  }
}

resource "kubernetes_secret" "this" {
  count      = var.create_controller ? 1 : 0
  depends_on = [null_resource.module_depends_on]

  metadata {
    name      = "spotinst-kubernetes-cluster-controller"
    namespace = "kube-system"
  }

  type = "Opaque"
  data = {
    "token"   = var.spotinst_token
    "account" = var.spotinst_account
  }
}

resource "kubernetes_config_map" "this" {
  count      = var.create_controller ? 1 : 0
  depends_on = [null_resource.module_depends_on]

  metadata {
    name      = "spotinst-kubernetes-cluster-controller-config"
    namespace = "kube-system"
  }

  data = {
    "spotinst.cluster-identifier" = var.cluster_identifier
    "base-url"                    = var.base_url
    "proxy-url"                   = var.proxy_url
    "enable-csr-approval"         = var.enable_csr_approval
    "disable-auto-update"         = var.disable_auto_update
  }
}

resource "kubernetes_service_account" "this" {
  count      = var.create_controller ? 1 : 0
  depends_on = [null_resource.module_depends_on]

  metadata {
    name      = "spotinst-kubernetes-cluster-controller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "this" {
  count      = var.create_controller ? 1 : 0
  depends_on = [null_resource.module_depends_on]

  metadata {
    name = "spotinst-kubernetes-cluster-controller"
  }

  # ---------------------------------------------------------------------------
  # Required for functional operation (read-only).
  # ---------------------------------------------------------------------------

  rule {
    api_groups = [""]
    resources  = ["pods", "nodes", "services", "namespaces", "replicationcontrollers", "limitranges", "events", "persistentvolumes", "persistentvolumeclaims"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["get", "list"]
  }

  rule {
    non_resource_urls = ["/version/", "/version"]
    verbs             = ["get"]
  }

  # ---------------------------------------------------------------------------
  # Required by the draining feature and for functional operation.
  # ---------------------------------------------------------------------------

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }

  # ---------------------------------------------------------------------------
  # Required by the Spotinst Cleanup feature.
  # ---------------------------------------------------------------------------

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["delete"]
  }

  # ---------------------------------------------------------------------------
  # Required by the Spotinst CSR approval feature.
  # ---------------------------------------------------------------------------

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests/approval"]
    verbs      = ["patch", "update"]
  }

  rule {
    api_groups     = ["certificates.k8s.io"]
    resources      = ["signers"]
    resource_names = ["kubernetes.io/kubelet-serving", "kubernetes.io/kube-apiserver-client-kubelet"]
    verbs          = ["approve"]
  }

  # ---------------------------------------------------------------------------
  # Required by the Spotinst Auto Update feature.
  # ---------------------------------------------------------------------------

  rule {
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["clusterroles"]
    resource_names = ["spotinst-kubernetes-cluster-controller"]
    verbs          = ["patch", "update", "escalate"]
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    resource_names = ["spotinst-kubernetes-cluster-controller"]
    verbs          = ["patch", "update"]
  }

  # ---------------------------------------------------------------------------
  # Required by the Spotinst Apply feature.
  # ---------------------------------------------------------------------------

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets"]
    verbs      = ["get", "list", "patch", "update", "create", "delete"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["daemonsets"]
    verbs      = ["get", "list", "patch", "update", "create", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "patch", "update", "create", "delete"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "patch", "update", "create", "delete"]
  }

  # ---------------------------------------------------------------------------
  # Required by the Spotinst Wave.
  # ---------------------------------------------------------------------------

  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications", "scheduledsparkapplications"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["wave.spot.io"]
    resources  = ["sparkapplications", "wavecomponents", "waveenvironments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  count      = var.create_controller ? 1 : 0
  depends_on = [null_resource.module_depends_on]

  metadata {
    name = "spotinst-kubernetes-cluster-controller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "spotinst-kubernetes-cluster-controller"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "spotinst-kubernetes-cluster-controller"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "this" {
  count      = var.create_controller ? 1 : 0
  depends_on = [null_resource.module_depends_on]

  metadata {
    name      = "spotinst-kubernetes-cluster-controller"
    namespace = "kube-system"

    labels = {
      k8s-app = "spotinst-kubernetes-cluster-controller"
    }
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = {
        k8s-app = "spotinst-kubernetes-cluster-controller"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "spotinst-kubernetes-cluster-controller"
        }
      }

      spec {
        dynamic "image_pull_secrets" {
          for_each = toset(var.image_pull_secrets)
          content {
            name = image_pull_secrets.key
          }
        }

        priority_class_name = "system-cluster-critical"

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/os"
                  operator = "NotIn"
                  values   = ["windows"]
                }
              }
            }

            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              preference {
                match_expressions {
                  key      = "node-role.kubernetes.io/master"
                  operator = "Exists"
                }
              }
            }
          }

          pod_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "k8s-app"
                    operator = "In"
                    values   = ["spotinst-kubernetes-cluster-controller"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        container {
          image             = "${var.controller_image}:${var.controller_version}"
          name              = "spotinst-kubernetes-cluster-controller"
          image_pull_policy = var.image_pull_policy

          resources {
            limits   = var.resources_limits
            requests = var.resources_requests
          }

          liveness_probe {
            http_get {
              path = "/healthcheck"
              port = 4401
            }

            initial_delay_seconds = 300
            period_seconds        = 20
            timeout_seconds       = 2
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/healthcheck"
              port = 4401
            }

            initial_delay_seconds = 20
            period_seconds        = 20
            timeout_seconds       = 2
            success_threshold     = 1
            failure_threshold     = 3
          }

          env {
            name = "SPOTINST_TOKEN"

            value_from {
              secret_key_ref {
                name     = "spotinst-kubernetes-cluster-controller"
                key      = "token"
                optional = true
              }
            }
          }

          env {
            name = "SPOTINST_ACCOUNT"

            value_from {
              secret_key_ref {
                name     = "spotinst-kubernetes-cluster-controller"
                key      = "account"
                optional = true
              }
            }
          }

          env {
            name = "SPOTINST_TOKEN_LEGACY"

            value_from {
              config_map_key_ref {
                name     = "spotinst-kubernetes-cluster-controller-config"
                key      = "spotinst.token"
                optional = true
              }
            }
          }

          env {
            name = "SPOTINST_ACCOUNT_LEGACY"

            value_from {
              config_map_key_ref {
                name     = "spotinst-kubernetes-cluster-controller-config"
                key      = "spotinst.account"
                optional = true
              }
            }
          }

          env {
            name = "CLUSTER_IDENTIFIER"

            value_from {
              config_map_key_ref {
                name = "spotinst-kubernetes-cluster-controller-config"
                key  = "spotinst.cluster-identifier"
              }
            }
          }

          env {
            name = "BASE_SPOTINST_URL"

            value_from {
              config_map_key_ref {
                name = "spotinst-kubernetes-cluster-controller-config"
                key  = "base-url"
              }
            }
          }

          env {
            name = "PROXY_URL"

            value_from {
              config_map_key_ref {
                name = "spotinst-kubernetes-cluster-controller-config"
                key  = "proxy-url"
              }
            }
          }

          env {
            name = "ENABLE_CSR_APPROVAL"

            value_from {
              config_map_key_ref {
                name = "spotinst-kubernetes-cluster-controller-config"
                key  = "enable-csr-approval"
              }
            }
          }

          env {
            name = "DISABLE_AUTO_UPDATE"

            value_from {
              config_map_key_ref {
                name = "spotinst-kubernetes-cluster-controller-config"
                key  = "disable-auto-update"
              }
            }
          }

          env {
            name = "POD_ID"

            value_from {
              field_ref {
                field_path = "metadata.uid"
              }
            }
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
        }

        service_account_name            = "spotinst-kubernetes-cluster-controller"
        automount_service_account_token = true
        dns_policy                      = "Default"

        dynamic "toleration" {
          for_each = var.tolerations

          content {
            key                = lookup(toleration.value, "key", null)
            value              = lookup(toleration.value, "value", null)
            effect             = lookup(toleration.value, "effect", null)
            operator           = lookup(toleration.value, "operator", null)
            toleration_seconds = lookup(toleration.value, "toleration_seconds", null)
          }
        }

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
        }
      }
    }
  }
}

resource "kubernetes_job" "this" {
  count      = var.aks_connector_enabled && var.acd_identifier != null ? 1 : 0
  depends_on = [null_resource.module_depends_on]

  metadata {
    name      = "spotinst-kubernetes-cluster-controller-aks-connector"
    namespace = "kube-system"

    labels = {
      k8s-app = "spotinst-kubernetes-cluster-controller-aks-connector"
    }
  }

  spec {
    template {
      metadata {
        labels = {
          k8s-app = "spotinst-kubernetes-cluster-controller-aks-connector"
        }
      }

      spec {
        node_selector = {
          "kubernetes.azure.com/mode" = "system"
        }

        dynamic "image_pull_secrets" {
          for_each = toset(var.image_pull_secrets)
          content {
            name = image_pull_secrets.key
          }
        }

        container {
          image             = "${var.aks_connector_image}:${var.aks_connector_version}"
          name              = "ocean-aks-connector"
          image_pull_policy = var.image_pull_policy
          args              = ["connect-ocean"]

          resources {
            limits   = var.resources_limits
            requests = var.resources_requests
          }

          env {
            name = "SPOT_TOKEN"

            value_from {
              secret_key_ref {
                name     = "spotinst-kubernetes-cluster-controller"
                key      = "token"
                optional = true
              }
            }
          }

          env {
            name = "SPOT_ACCOUNT"

            value_from {
              secret_key_ref {
                name     = "spotinst-kubernetes-cluster-controller"
                key      = "account"
                optional = true
              }
            }
          }

          env {
            name = "SPOT_CLUSTER_IDENTIFIER"

            value_from {
              config_map_key_ref {
                name = "spotinst-kubernetes-cluster-controller-config"
                key  = "spotinst.cluster-identifier"
              }
            }
          }

          env {
            name  = "SPOT_ACD_IDENTIFIER"
            value = var.acd_identifier
          }

          security_context {
            allow_privilege_escalation = false
            run_as_user                = 0
          }

          volume_mount {
            name       = "waagent"
            mount_path = "/var/lib/waagent"
          }
        }

        volume {
          name = "waagent"

          host_path {
            type = "Directory"
            path = "/var/lib/waagent"
          }
        }

        dns_policy     = "Default"
        restart_policy = "Never"
      }
    }
  }
}
