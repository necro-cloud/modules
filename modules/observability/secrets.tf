// Observability Password
resource "random_password" "observability_password" {
  length           = 20
  lower            = true
  numeric          = true
  special          = true
  override_special = "-_*/"
  min_special      = 3
}

resource "kubernetes_secret" "observability_credentials" {
  metadata {
    name      = "observability-credentials"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    username = "observability.admin"
    password = random_password.observability_password.result
  }

  type = "Opaque"
}
