// Kubernetes Ingress for API Access
resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "ingress"
    }
    annotations = {
      "traefik.ingress.kubernetes.io/router.middlewares" = join(",", [
        "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.middleware_rewrite.manifest.metadata.name}@kubernetescrd",
        "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.middleware_buffering.manifest.metadata.name}@kubernetescrd"
      ])
      "traefik.ingress.kubernetes.io/service.serverstransport" = "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.transport.manifest.metadata.name}@kubernetescrd"
      "traefik.ingress.kubernetes.io/router.tls"               = "true"
      "traefik.ingress.kubernetes.io/router.entrypoints"       = "websecure"
    }
  }

  spec {
    ingress_class_name = "traefik"
    tls {
      hosts       = ["api.${var.host_name}.${var.domain}"]
      secret_name = kubernetes_manifest.api_ingress_certificate.manifest.spec.secretName
    }
    rule {
      host = "api.${var.host_name}.${var.domain}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.garage-service.metadata[0].name
              port {
                name = "proxy-api"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_manifest.middleware_rewrite,
    kubernetes_manifest.middleware_buffering,
    kubernetes_manifest.transport,
  ]
}

// Kubernetes Ingress for UI Access
resource "kubernetes_ingress_v1" "ui_ingress" {
  count = var.enable_ui ? 1 : 0
  metadata {
    name      = "ui-ingress"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "ingress"
    }
    annotations = {
      "traefik.ingress.kubernetes.io/router.middlewares" = join(",", [
        "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.middleware_rewrite.manifest.metadata.name}@kubernetescrd",
        "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.middleware_buffering.manifest.metadata.name}@kubernetescrd"
      ])
      "traefik.ingress.kubernetes.io/service.serverstransport" = "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.transport.manifest.metadata.name}@kubernetescrd"
      "traefik.ingress.kubernetes.io/router.tls"               = "true"
      "traefik.ingress.kubernetes.io/router.entrypoints"       = "websecure"
    }
  }

  spec {
    ingress_class_name = "traefik"
    tls {
      hosts       = ["${var.host_name}.${var.domain}"]
      secret_name = kubernetes_manifest.ui_ingress_certificate[0].manifest.spec.secretName
    }
    rule {
      host = "${var.host_name}.${var.domain}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.garage-ui-service[0].metadata[0].name
              port {
                name = "ui"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_manifest.middleware_rewrite,
    kubernetes_manifest.middleware_buffering,
    kubernetes_manifest.transport,
  ]
}
