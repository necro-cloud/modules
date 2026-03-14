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

resource "kubernetes_manifest" "push_rpc_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-rpc-secret"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      deletionPolicy  = "None"
      secretStoreRefs = [{
        name = var.cluster_secret_store_name
        kind = "ClusterSecretStore"
      }]
      selector = {
        secret = {
          name = kubernetes_secret.rpc_secret.metadata[0].name
        }
      }
      data = [{
        match = {
          remoteRef = {
            remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/infrastructure/${kubernetes_secret.rpc_secret.metadata[0].name}"
          }
        }
      }]
    }
  }
}

// Garage Admin Password required for cluster, buckets and access keys creation
resource "kubernetes_manifest" "admin_password_generator" {
  manifest = {
    apiVersion = "generators.external-secrets.io/v1alpha1"
    kind       = "Password"
    metadata = {
      name      = "admin-token-generator"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      length  = 32
      digits  = 10
      symbols = 0
      noUpper = true
    }
  }
}

resource "kubernetes_manifest" "admin_password_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "admin-password-sync"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0" 
      target = {
        name = "garage-admin-password"
        template = {
          data = {
            "GARAGE_ADMIN_TOKEN" = "{{ .password }}"
          }
        }
      }
      dataFrom = [{
        sourceRef = {
          generatorRef = {
            apiVersion = "generators.external-secrets.io/v1alpha1"
            kind       = "Password"
            name       = kubernetes_manifest.admin_password_generator.object.metadata.name
          }
        }
      }]
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
}

resource "kubernetes_manifest" "push_admin_password" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-admin-password"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      deletionPolicy  = "None"
      secretStoreRefs = [{
        name = var.cluster_secret_store_name
        kind = "ClusterSecretStore"
      }]
      selector = {
        secret = {
          name = kubernetes_manifest.admin_password_sync.object.spec.target.name
        }
      }
      data = [{
        match = {
          remoteRef = {
            remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/infrastructure/${kubernetes_manifest.admin_password_sync.object.spec.target.name}"
          }
        }
      }]
    }
  }
}
