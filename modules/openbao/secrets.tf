// Static Unsealing key to be used for OpenBao Auto-Unsealing
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

// Push the secret to OpenBao
resource "kubernetes_manifest" "static_unseal_key" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "static-unseal-key"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRefs = [
        {
          name = kubernetes_manifest.cluster_store.manifest.metadata.name
          kind = "ClusterSecretStore"
        }
      ]
      selector = {
        secret = {
          name = kubernetes_secret.static_unseal_key.metadata[0].name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/infrastructure/${kubernetes_secret.static_unseal_key.metadata[0].name}"
            }
          }
        }
      ]
    }
  }

  // Wait for the sync to complete
  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
  }

  // Waiting till the store and the source secret actually exist
  depends_on = [
    kubernetes_manifest.cluster_store,
    kubernetes_secret.static_unseal_key
  ]  
}
