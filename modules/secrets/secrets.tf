resource "random_id" "static_unseal_key" {
  byte_length = 32
}

resource "kubernetes_secret" "static_unseal_key" {
  metadata {
    name = "openbao-static-unseal-key"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    "OPENBAO_STATIC_UNSEAL_KEY" = random_id.static_unseal_key.b64_std
  }
}
