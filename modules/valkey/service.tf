// Headless Service for StatefulSet
resource "kubernetes_service" "headless_service" {
  metadata {
    name      = "valkey-headless-service"
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
      port        = 6379
      target_port = 6379
      name        = "valkey"
    }

    selector = {
      app       = var.app_name
      "part-of" = "valkey-cluster"
    }
  }
}

// Service for Exposing the Primary Node
resource "kubernetes_service" "primary_service" {
  metadata {
    name      = "valkey-primary-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "service"
    }
  }

  spec {
    port {
      port        = 6379
      target_port = 6379
      name        = "valkey"
    }

    selector = {
      app                                  = var.app_name
      "part-of"                            = "valkey-cluster"
      "statefulset.kubernetes.io/pod-name" = "valkey-cluster-0"
    }
  }
}

// Service for Exposing Replicas
resource "kubernetes_service" "replica_service" {
  metadata {
    name      = "valkey-replica-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "service"
    }
  }

  spec {
    port {
      port        = 6379
      target_port = 6379
      name        = "valkey"
    }

    selector = {
      app       = var.app_name
      "part-of" = "valkey-cluster"
    }
  }
}

// Service for Exposing Redis Commander
resource "kubernetes_service" "ui_service" {
  count = var.enable_ui ? 1 : 0
  metadata {
    name      = "valkey-ui-service"
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
    port {
      port        = var.enable_internal_tls_certificates ? 8443 : 8081
      target_port = var.enable_internal_tls_certificates ? 8443 : 8081
      name        = "ui"
    }

    selector = {
      app       = var.app_name
      component = "pod"
      "part-of" = "valkey-ui"
      "valkey-ui-access" = true
    }
  }
}
