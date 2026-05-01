# Ingress for accessing the Keycloak Cluster
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "ingress"
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
      "traefik.ingress.kubernetes.io/router.tls" = "true"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
    }
  }

  spec {
    ingress_class_name = "traefik"
    tls {
      hosts       = ["${var.host_name}.${var.domain}"]
      secret_name = kubernetes_manifest.ingress_certificate.manifest.spec.secretName
    }
    rule {
      host = "${var.host_name}.${var.domain}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.keycloak_service.metadata[0].name
              port {
                number = 8443
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
