# ==============================================================================
# Main Terraform Configuration for Kubernetes Deployment
# ==============================================================================

# Create Namespace
resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = var.namespace
  }
}

# External Postgres Service and Endpoints
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    port {
      name        = "postgres"
      port        = var.postgres_port
      target_port = var.postgres_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_endpoints" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  subset {
    address {
      ip = var.postgres_host
    }

    port {
      name     = "postgres"
      port     = var.postgres_port
      protocol = "TCP"
    }
  }
}

# External Redis Service and Endpoints
resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    port {
      name        = "redis"
      port        = var.redis_port
      target_port = var.redis_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_endpoints" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  subset {
    address {
      ip = var.redis_host
    }

    port {
      name     = "redis"
      port     = var.redis_port
      protocol = "TCP"
    }
  }
}

# App ConfigMap
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  data = {
    APP_NAME  = var.app_name
    PORT      = "8000"
    REDIS_URL = "redis://:${var.redis_password}@redis:${var.redis_port}/0"
  }
}

# App Secret
resource "kubernetes_secret" "app_secret" {
  metadata {
    name      = "${var.app_name}-secret"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  type = "Opaque"

  data = {
    DATABASE_URL = "postgresql://${var.postgres_user}:${var.postgres_password}@postgres:${var.postgres_port}/${var.postgres_db}"
  }
}

# App Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app_ns.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.app_replicas

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 10001
          run_as_group    = 10001
          fs_group        = 10001
        }

        container {
          name              = var.app_name
          image             = "${var.image_repository}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 8000
          }

          env {
            name = "APP_NAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.app_config.metadata[0].name
                key  = "APP_NAME"
              }
            }
          }

          env {
            name = "PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.app_config.metadata[0].name
                key  = "PORT"
              }
            }
          }

          env {
            name = "REDIS_URL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.app_config.metadata[0].name
                key  = "REDIS_URL"
              }
            }
          }

          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secret.metadata[0].name
                key  = "DATABASE_URL"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/readyz"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 3
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

# App Service
resource "kubernetes_service" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    type = "ClusterIP"
    port {
      name        = "http"
      port        = 8000
      target_port = "http"
      protocol    = "TCP"
    }

    selector = {
      app = var.app_name
    }
  }
}

# App PodDisruptionBudget
resource "kubernetes_pod_disruption_budget_v1" "app" {
  metadata {
    name      = "${var.app_name}-pdb"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    min_available = "2"
    selector {
      match_labels = {
        app = var.app_name
      }
    }
  }
}

# App Network Policy
resource "kubernetes_network_policy" "app" {
  metadata {
    name      = "${var.app_name}-netpol"
    namespace = kubernetes_namespace.app_ns.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = var.app_name
      }
    }

    ingress {
      ports {
        port     = "8000"
        protocol = "TCP"
      }
    }

    egress {
      # DNS Egress
      to {
        namespace_selector {}
        pod_selector {
          match_labels = {
            k8s-app = "kube-dns"
          }
        }
      }
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }

    egress {
      # PostgreSQL Egress
      to {
        ip_block {
          cidr = "${var.postgres_host}/32"
        }
      }
      ports {
        port     = var.postgres_port
        protocol = "TCP"
      }
    }

    egress {
      # Redis Egress
      to {
        ip_block {
          cidr = "${var.redis_host}/32"
        }
      }
      ports {
        port     = var.redis_port
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress", "Egress"]
  }
}

# App HTTPRoute (Gateway API)
resource "kubernetes_manifest" "ledger_api_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "ledger-api-route"
      namespace = kubernetes_namespace.app_ns.metadata[0].name
    }
    spec = {
      hostnames = [
        "ledger-mm-test.vennpham.work",
        "ledger-mm-test.vennpham.local"
      ]
      parentRefs = [
        {
          group     = "gateway.networking.k8s.io"
          kind      = "Gateway"
          name      = "main-gateway"
          namespace = "default"
        }
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          backendRefs = [
            {
              name = kubernetes_service.app.metadata[0].name
              port = kubernetes_service.app.spec[0].port[0].port
            }
          ]
        }
      ]
    }
  }
}
