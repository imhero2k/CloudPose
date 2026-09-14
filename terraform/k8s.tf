resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }

  depends_on = [aws_eks_node_group.this]
}

resource "kubernetes_deployment_v1" "api" {
  metadata {
    name      = "pose-estimator"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = { app = "pose-estimator" }
  }

  spec {
    replicas = var.api_replicas

    selector {
      match_labels = { app = "pose-estimator" }
    }

    template {
      metadata {
        labels = { app = "pose-estimator" }
      }

      spec {
        container {
          name              = "pose-container"
          image             = "${aws_ecr_repository.api.repository_url}:${var.image_tag}"
          image_pull_policy = "Always"

          port {
            container_port = 80
            protocol       = "TCP"
          }

          env {
            name  = "PORT"
            value = "80"
          }

          env {
            name  = "CORS_ORIGINS"
            value = var.cors_origins
          }

          resources {
            requests = {
              cpu    = var.api_cpu
              memory = var.api_memory
            }
            limits = {
              cpu    = var.api_cpu
              memory = var.api_memory
            }
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 20
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 40
            period_seconds        = 20
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "api" {
  metadata {
    name      = "pose-estimator-service"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = { app = "pose-estimator" }
  }

  spec {
    selector = { app = "pose-estimator" }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name      = "cloudpose-frontend"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = { app = "cloudpose-frontend" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "cloudpose-frontend" }
    }

    template {
      metadata {
        labels = { app = "cloudpose-frontend" }
      }

      spec {
        container {
          name              = "nginx"
          image             = "${aws_ecr_repository.frontend.repository_url}:${var.image_tag}"
          image_pull_policy = "Always"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service_v1.api]
}

resource "kubernetes_service_v1" "frontend" {
  metadata {
    name      = "cloudpose-frontend"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = { app = "cloudpose-frontend" }
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
    }
  }

  spec {
    selector = { app = "cloudpose-frontend" }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}
