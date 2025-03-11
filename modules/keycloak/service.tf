// Keycloak Discovery Service
resource "kubernetes_service" "keycloak_discovery" {
  metadata {
    name      = "keycloak-discovery"
    namespace = var.namespace
  }

  spec {
    selector = {
      app       = "keycloak"
      component = "pod"
    }
    session_affinity = "None"
    port {
      name        = "discovery"
      port        = 7800
      target_port = "discovery"
    }
    type       = "ClusterIP"
    cluster_ip = "None"
  }
}

// Keycloak HTTP(S) and Management Service
resource "kubernetes_service" "keycloak_service" {
  metadata {
    name      = "keycloak-cluster-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app       = "keycloak"
      component = "pod"
    }
    session_affinity = "None"
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
    port {
      name        = "https"
      port        = 8443
      target_port = "https"
    }
    port {
      name        = "management"
      port        = 9000
      target_port = "management"
    }
    type = "ClusterIP"
  }
}
