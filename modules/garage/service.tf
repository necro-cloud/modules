// StatefulSet Headless Service
resource "kubernetes_service" "garage-headless" {
  metadata {
    name      = "garage-headless"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "service"
    }
  }

  spec {
    type       = "ClusterIP"
    cluster_ip = null

    port {
      port        = 3901
      target_port = 3901
      name        = "rpc"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      "part-of" = "garage"
    }
  }
}

// Garage Service for Ingress Usage and Cluster Discovery
resource "kubernetes_service" "garage-service" {
  metadata {
    name      = "garage-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "service"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 3940
      target_port = 3940
      name        = "proxy-api"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      "part-of" = "garage"
    }
  }
}
