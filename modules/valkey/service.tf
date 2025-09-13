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
