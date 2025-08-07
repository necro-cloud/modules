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
      port        = 3903
      target_port = 3903
      name        = "admin"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      part_of   = "statefulset"
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
      port        = 3903
      target_port = 3903
      name        = "admin"
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

    port {
      port        = 3943
      target_port = 3943
      name        = "proxy-admin"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      part_of   = "statefulset"
    }
  }
}
