// Namespace for the Garage Cluster to be deployed in
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
    labels = {
      app       = var.app_name
      component = "namespace"
    }
  }
}
