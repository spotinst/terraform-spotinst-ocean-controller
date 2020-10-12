resource "kubernetes_secret" "this" {
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
  metadata {
    name      = "spotinst-kubernetes-cluster-controller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "this" {
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
}

resource "kubernetes_cluster_role_binding" "this" {
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
        priority_class_name = "system-cluster-critical"

        affinity {
          node_affinity {
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
          image             = "spotinst/kubernetes-cluster-controller:1.0.67"
          name              = "spotinst-kubernetes-cluster-controller"
          image_pull_policy = "Always"

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

        toleration {
          key                = "node.kubernetes.io/not-ready"
          effect             = "NoExecute"
          operator           = "Exists"
          toleration_seconds = 150
        }

        toleration {
          key                = "node.kubernetes.io/unreachable"
          effect             = "NoExecute"
          operator           = "Exists"
          toleration_seconds = 150
        }

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
        }
      }
    }
  }
}
