// Garage RPC Secret required for nodes formation
resource "random_bytes" "rpc_secret" {
  length = 32
}

resource "kubernetes_secret" "rpc_secret" {
  metadata {
    name      = "garage-rpc-secret"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    "GARAGE_RPC_SECRET" = random_bytes.rpc_secret.hex
  }
}

// Garage Admin Password required for cluster, buckets and access keys creation
resource "random_password" "admin_password" {
  length      = 32
  special     = false
  numeric     = true
  min_numeric = 10
  upper       = false
}

resource "kubernetes_secret" "admin_password" {
  metadata {
    name      = "garage-admin-password"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    "GARAGE_ADMIN_TOKEN" = random_password.admin_password.result
  }
}
