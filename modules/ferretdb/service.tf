resource "kubernetes_service" "ferret_service" {
  metadata {
    name = "ferret-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = var.app_name
      component = "service"
    }
  }

  spec {
    selector = {
      app = var.app_name
      component = "pod"
      "part-of" = "ferretdb"
    }

    port {
      name = "mongo"
      port = 27017
      target_port = 27017
      protocol = "TCP"
    }

    type = "ClusterIP"
  }
}
