provider "kubernetes" {
  version = "~> 1.0"
}

resource "kubernetes_namespace" "ghost" {
  metadata {
    name = var.name
    labels = {
      "app.kubernetes.io/name" = "ghost"
    }
  }
}

resource "kubernetes_role" "ghost" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = "ghost"
    }
  }
  rule {
    api_groups     = [""]
    resources      = [""]
    resource_names = [""]
    verbs          = [""]
  }
}

resource "kubernetes_role_binding" "ghost" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = "ghost"
    }
  }
  subject {
    kind = "ServiceAccount"
    name = var.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = var.name
  }
}

resource "kubernetes_service_account" "ghost" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = "ghost"
    }
  }
}

resource "kubernetes_service" "ghost" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = "ghost"
    }
  }
  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 2368
    }
    selector = {
      "app.kubernetes.io/name" = "ghost"
    }
    type                    = "LoadBalancer"
    external_traffic_policy = "Local"
  }
}

resource "kubernetes_ingress" "ghost" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = "ghost"
    }
  }
  spec {
    rule {
      host = replace(var.url, "/(http|https)\\:\\/\\//", "")
      http {
        path {
          path = "/"
          backend {
            service_name = var.name
            service_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "ghost_content" {
  metadata {
    name      = "${var.name}-content"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = "ghost"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}

resource "kubernetes_deployment" "ghost" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = "ghost"
    }
  }
  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "ghost"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "ghost"
        }
      }
      spec {
        volume {
          name = "content"
          persistent_volume_claim {
            claim_name = "${var.name}-content"
          }
        }
        container {
          name  = "ghost"
          image = var.image_name
          image_pull_policy = var.image_pull_policy
          port {
            name           = "http"
            protocol       = "TCP"
            container_port = 2368
          }
          env {
            name  = "url"
            value = var.url
          }
          resources {
            limits {
              cpu    = var.resource_limit_cpu
              memory = var.resource_limit_mem
            }
            requests {
              cpu    = var.resource_req_cpu
              memory = var.resource_req_mem
            }
          }
          volume_mount {
            name       = "content"
            mount_path = "/var/lib/ghost/content"
          }
          readiness_probe {
            http_get {
              path   = "/"
              port   = 2368
              scheme = "HTTP"
            }
            initial_delay_seconds = 5
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }
          security_context {
            capabilities {
              drop = ["ALL"]
            }
            run_as_user     = 10001
            run_as_group    = 10001
            run_as_non_root = true
          }
        }
        security_context {
          fs_group = 10001
        }
      }
    }
    revision_history_limit = 10
  }
}
