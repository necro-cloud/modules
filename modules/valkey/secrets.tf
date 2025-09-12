// Valkey Password Secret
resource "random_password" "valkey_password" {
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "valkey_password" {
  metadata {
    name      = "valkey-password"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.replication_namespaces
    }
  }

  data = {
    VALKEY_PASSWORD = random_password.valkey_password.result
  }
}
