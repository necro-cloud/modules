// Kubernetes Ingress for Mongo Express Access
resource "kubernetes_ingress_v1" "mongo_express_ingress" {
  metadata {
    name      = "mongo-express-ingress"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "ingress"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/proxy-ssl-verify" : "on"
      "nginx.ingress.kubernetes.io/proxy-ssl-secret" : "${kubernetes_namespace.namespace.metadata[0].name}/${kubernetes_manifest.mongo_express_internal_certificate.manifest.spec.secretName}"
      "nginx.ingress.kubernetes.io/proxy-ssl-name" : "database.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
      "nginx.ingress.kubernetes.io/backend-protocol" : "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/"
      "nginx.ingress.kubernetes.io/proxy-body-size" : 0
      "nginx.ingress.kubernetes.io/client-body-buffer-size" : "500M"
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
              name = kubernetes_service.mongo_express.metadata[0].name
              port {
                name = "https"
              }
            }
          }
        }
      }
    }
  }
}
