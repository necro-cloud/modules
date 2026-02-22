# Ingress for accessing the Grafana
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "ingress"
    namespace = var.namespace
    labels = {
      app       = var.app_name
      component = "ingress"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/proxy-ssl-verify" : "on"
      "nginx.ingress.kubernetes.io/proxy-ssl-secret" : "${kubernetes_namespace.namespace.metadata[0].name}/${kubernetes_manifest.internal_certificate.manifest.spec.secretName}"
      "nginx.ingress.kubernetes.io/proxy-ssl-name" : "grafana.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
      "nginx.ingress.kubernetes.io/backend-protocol" : "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/"
      "nginx.ingress.kubernetes.io/proxy-body-size" : 0
    }
  }

  spec {
    ingress_class_name = "nginx"
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
              name = helm_release.grafana.name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
