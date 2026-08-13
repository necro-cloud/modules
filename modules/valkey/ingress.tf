// Kubernetes Ingress for Redis Commander
resource "kubernetes_ingress_v1" "ui_ingress" {
  count = var.enable_ui ? 1 : 0
  metadata {
    name      = "ui-ingress"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "ingress"
    }

    // Attaching all middlewares and server transports
    annotations = {
      "traefik.ingress.kubernetes.io/router.middlewares" = join(",", [
        "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.middleware_rewrite[0].manifest.metadata.name}@kubernetescrd",
        "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.middleware_buffering[0].manifest.metadata.name}@kubernetescrd"
      ])
      "traefik.ingress.kubernetes.io/service.serverstransport" = "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.transport[0].manifest.metadata.name}@kubernetescrd"
      "traefik.ingress.kubernetes.io/router.tls"               = "true"
      "traefik.ingress.kubernetes.io/router.entrypoints"       = "websecure"
    }
  }

  spec {
    ingress_class_name = "traefik"
    tls {
      hosts       = ["${var.host_name}.${var.domain}"]
      secret_name = kubernetes_manifest.ingress_certificate[0].manifest.spec.secretName
    }
    rule {
      host = "${var.host_name}.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.ui_service[0].metadata[0].name
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
    kubernetes_manifest.ingress_certificate
  ]
}
