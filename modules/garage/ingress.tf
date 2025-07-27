resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "ingress"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/proxy-ssl-verify" : "on"
      "nginx.ingress.kubernetes.io/proxy-ssl-secret" : "${kubernetes_namespace.namespace.metadata[0].name}/${kubernetes_manifest.internal_certificate.manifest.spec.secretName}"
      "nginx.ingress.kubernetes.io/proxy-ssl-name" : "garage.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
      "nginx.ingress.kubernetes.io/backend-protocol" : "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/"
      "nginx.ingress.kubernetes.io/proxy-body-size" : 0
    }
  }

  spec {
    ingress_class_name = "nginx"
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
              name = "garage-service"
              port {
                name = "proxy-api"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.minio_tenant]
}
