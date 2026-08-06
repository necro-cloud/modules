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
    annotations = {
      "traefik.ingress.kubernetes.io/service.serversscheme" = "https"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = local.garage_port
      target_port = local.garage_port
      name        = "proxy-api"
    }

    port {
      port        = local.garage_admin_port
      target_port = local.garage_admin_port
      name        = "admin-api"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      "part-of" = "garage"
    }
  }
}

// Garage UI Service for Ingress Usage
resource "kubernetes_service" "garage-ui-service" {
  metadata {
    name      = "garage-ui-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "service"
    }
    annotations = {
      "traefik.ingress.kubernetes.io/service.serversscheme" = "https"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 8443
      target_port = 8443
      name        = "https"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      "part-of" = "garage-ui"
    }
  }
}
