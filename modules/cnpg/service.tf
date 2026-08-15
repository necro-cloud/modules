// Garage Service for Ingress Usage
resource "kubernetes_service" "pgadmin4" {
  count = var.enable_ui ? 1 : 0
  metadata {
    name      = "pgadmin4-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "service"
    }
    annotations = {
      "traefik.ingress.kubernetes.io/service.serversscheme" = var.enable_internal_tls_certificates ? "https" : "http"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 443
      target_port = 443
      name        = "https"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      used-for  = "pgadmin"
    }
  }
}
