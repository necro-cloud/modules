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
      port        = 3900
      target_port = 3900
      name        = "api"
    }

    port {
      port        = 3902
      target_port = 3902
      name        = "web"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      part_of   = "statefulset"
    }
  }
}

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
      port        = 3900
      target_port = 3900
      name        = "api"
    }

    port {
      port        = 3902
      target_port = 3902
      name        = "web"
    }

    port {
      port        = 3940
      target_port = 3940
      name        = "proxy-api"
    }

    port {
      port        = 3942
      target_port = 3942
      name        = "proxy-web"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      part_of   = "statefulset"
    }
  }
}
