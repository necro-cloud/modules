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
      "traefik.ingress.kubernetes.io/service.serversscheme" = var.enable_internal_tls_certificates ? "https" : "http"
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
  count = var.enable_ui ? 1 : 0
  metadata {
    name      = "garage-ui-service"
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
      port        = local.ui_port
      target_port = local.ui_port
      name        = "ui"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      "part-of" = "garage-ui"
    }
  }
}
