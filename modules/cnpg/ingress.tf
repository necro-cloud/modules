// Kubernetes Ingress for PGAdmin Access
resource "kubernetes_ingress_v1" "api_ingress" {
  count = var.enable_ui ? 1 : 0
  metadata {
    name      = "api-ingress"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "ingress"
    }
    annotations = {
      "traefik.ingress.kubernetes.io/router.middlewares" = join(",", [
        "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.middleware_rewrite[0].manifest.metadata.name}@kubernetescrd",
        "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.middleware_buffering[0].manifest.metadata.name}@kubernetescrd"
      ])
      "traefik.ingress.kubernetes.io/service.serverstransport" = "${kubernetes_namespace.namespace.metadata[0].name}-${kubernetes_manifest.transport[0].manifest.metadata.name}@kubernetescrd"
      "traefik.ingress.kubernetes.io/router.tls" = "true"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
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
          path = "/"
          backend {
            service {
              name = kubernetes_service.pgadmin4[0].metadata[0].name
              port {
                name = "https"
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
