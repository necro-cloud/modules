// Namespace configuration for Keycloak Identity Platform solution
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
    labels = {
      app       = var.app_name
      component = "namespace"
    }
  }
}
