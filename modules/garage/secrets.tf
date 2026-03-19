// Garage RPC Secret required for nodes formation
resource "kubernetes_manifest" "garage_rpc_generator" {
  manifest = {
    apiVersion = "generators.external-secrets.io/v1alpha1"
    kind       = "Password"
    metadata = {
      name      = "garage-rpc-generator"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      length   = 32
      encoding = "hex"
    }
  }
}

resource "kubernetes_manifest" "garage_rpc_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "garage-rpc-secret"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "garage-rpc-secret"
        template = {
          data = {
            "GARAGE_RPC_SECRET" = "{{ .password }}"
          }
        }
      }
      dataFrom = [{
        sourceRef = {
          generatorRef = {
            apiVersion = "generators.external-secrets.io/v1alpha1"
            kind       = "Password"
            name       = kubernetes_manifest.garage_rpc_generator.object.metadata.name
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "push_garage_rpc_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-garage-rpc-secret"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRefs = [{
        name = var.cluster_secret_store_name
        kind = "ClusterSecretStore"
      }]
      selector = {
        secret = {
          name = "garage-rpc-secret"
        }
      }
      data = [{
        match = {
          remoteRef = {
            remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/credentials/garage/rpc-secret"
          }
        }
      }]
    }
  }
  depends_on = [kubernetes_manifest.garage_rpc_sync]
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
