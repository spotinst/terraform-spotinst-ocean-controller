locals {
  prefix                 = "spotinst-kubernetes-cluster-controller"
  namespace              = "kube-system"
  secret_name            = coalesce(var.secret_name, local.prefix)
  service_account_name   = coalesce(var.service_account_name, local.prefix)
  config_map_name        = coalesce(var.config_map_name, format("%s-config", local.prefix))
  ca_bundle_secret_name  = coalesce(var.ca_bundle_secret_name, format("%s-ca-bundle", local.prefix))
  aks_connector_job_name = coalesce(var.aks_connector_job_name, format("%s-aks-connector", local.prefix))
}

resource "kubernetes_secret" "this" {
  count = var.create_controller ? 1 : 0

  metadata {
    name      = local.secret_name
    namespace = local.namespace
  }

  type = "Opaque"
  data = {
    "token"   = var.spotinst_token
    "account" = var.spotinst_account
  }
}

resource "kubernetes_config_map" "this" {
  count = var.create_controller ? 1 : 0

  metadata {
    name      = local.config_map_name
    namespace = local.namespace
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
  count = var.create_controller ? 1 : 0

  metadata {
    name      = local.service_account_name
    namespace = local.namespace
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "this" {
  count = var.create_controller ? 1 : 0

  metadata {
    name = local.prefix
  }

  # ---------------------------------------------------------------------------
  # feature: ocean/readonly
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
  # feature: ocean/draining
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
  # feature: ocean/cleanup
  # ---------------------------------------------------------------------------

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["delete"]
  }

  # ---------------------------------------------------------------------------
  # feature: ocean/csr-approval
  # ---------------------------------------------------------------------------

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
    verbs      = ["get", "list", "create", "delete"]
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
  # feature: ocean/auto-update
  # ---------------------------------------------------------------------------

  rule {
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["clusterroles"]
    resource_names = [local.prefix]
    verbs          = ["patch", "update", "escalate"]
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    resource_names = [local.prefix]
    verbs          = ["patch", "update"]
  }

  # ---------------------------------------------------------------------------
  # feature: ocean/apply
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
  # feature: wave
  # ---------------------------------------------------------------------------

  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications", "scheduledsparkapplications"]
    verbs      = ["get", "list", "patch", "update", "create", "delete"]
  }

  rule {
    api_groups = ["wave.spot.io"]
    resources  = ["sparkapplications", "wavecomponents", "waveenvironments"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["bigdata.spot.io"]
    resources  = ["bigdataenvironments"]
    verbs      = ["get", "list", "patch", "update", "create", "delete"]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  count = var.create_controller ? 1 : 0

  depends_on = [
    kubernetes_cluster_role.this,
    kubernetes_service_account.this,
  ]

  metadata {
    name = local.prefix
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this[0].metadata[0].name
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this[0].metadata[0].name
    namespace = kubernetes_service_account.this[0].metadata[0].namespace
  }
}

resource "kubernetes_deployment" "this" {
  count = var.create_controller ? 1 : 0

  depends_on = [
    kubernetes_config_map.this,
    kubernetes_secret.this,
    kubernetes_service_account.this,
  ]

  metadata {
    name      = local.prefix
    namespace = local.namespace

    labels = {
      k8s-app = local.prefix
    }
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = {
        k8s-app = local.prefix
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = local.prefix
        }
      }

      spec {
        node_selector = var.node_selector

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
                    values   = [local.prefix]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        container {
          image             = format("%s:%s", var.controller_image, var.controller_version)
          name              = local.prefix
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
                name     = kubernetes_secret.this[0].metadata[0].name
                key      = "token"
                optional = true
              }
            }
          }

          env {
            name = "SPOTINST_ACCOUNT"

            value_from {
              secret_key_ref {
                name     = kubernetes_secret.this[0].metadata[0].name
                key      = "account"
                optional = true
              }
            }
          }

          env {
            name = "SPOTINST_TOKEN_LEGACY"

            value_from {
              config_map_key_ref {
                name     = kubernetes_config_map.this[0].metadata[0].name
                key      = "spotinst.token"
                optional = true
              }
            }
          }

          env {
            name = "SPOTINST_ACCOUNT_LEGACY"

            value_from {
              config_map_key_ref {
                name     = kubernetes_config_map.this[0].metadata[0].name
                key      = "spotinst.account"
                optional = true
              }
            }
          }

          env {
            name = "CLUSTER_IDENTIFIER"

            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.this[0].metadata[0].name
                key  = "spotinst.cluster-identifier"
              }
            }
          }

          env {
            name = "BASE_SPOTINST_URL"

            value_from {
              config_map_key_ref {
                name     = kubernetes_config_map.this[0].metadata[0].name
                key      = "base-url"
                optional = true
              }
            }
          }

          env {
            name = "PROXY_URL"

            value_from {
              config_map_key_ref {
                name     = kubernetes_config_map.this[0].metadata[0].name
                key      = "proxy-url"
                optional = true
              }
            }
          }

          env {
            name = "ENABLE_CSR_APPROVAL"

            value_from {
              config_map_key_ref {
                name     = kubernetes_config_map.this[0].metadata[0].name
                key      = "enable-csr-approval"
                optional = true
              }
            }
          }

          env {
            name = "DISABLE_AUTO_UPDATE"

            value_from {
              config_map_key_ref {
                name     = kubernetes_config_map.this[0].metadata[0].name
                key      = "disable-auto-update"
                optional = true
              }
            }
          }

          env {
            name = "USER_ENV_CERTIFICATES"

            value_from {
              secret_key_ref {
                name     = local.ca_bundle_secret_name
                key      = "userEnvCertificates.pem"
                optional = true
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

        service_account_name            = kubernetes_service_account.this[0].metadata[0].name
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
  count = var.create_controller && var.aks_connector_enabled && var.acd_identifier != null ? 1 : 0

  depends_on = [
    kubernetes_config_map.this,
    kubernetes_secret.this,
  ]

  metadata {
    name      = local.aks_connector_job_name
    namespace = local.namespace

    labels = {
      k8s-app = local.aks_connector_job_name
    }
  }

  spec {
    template {
      metadata {
        labels = {
          k8s-app = local.aks_connector_job_name
        }
      }

      spec {
        node_selector = merge(var.node_selector, { "kubernetes.azure.com/mode" = "system" })

        dynamic "image_pull_secrets" {
          for_each = toset(var.image_pull_secrets)
          content {
            name = image_pull_secrets.key
          }
        }

        container {
          image             = format("%s:%s", var.aks_connector_image, var.aks_connector_version)
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
                name     = kubernetes_secret.this[0].metadata[0].name
                key      = "token"
                optional = true
              }
            }
          }

          env {
            name = "SPOT_ACCOUNT"

            value_from {
              secret_key_ref {
                name     = kubernetes_secret.this[0].metadata[0].name
                key      = "account"
                optional = true
              }
            }
          }

          env {
            name = "SPOT_CLUSTER_IDENTIFIER"

            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.this[0].metadata[0].name
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
