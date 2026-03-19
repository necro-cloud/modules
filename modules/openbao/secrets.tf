// Static Unsealing key to be used for OpenBao Auto-Unsealing
resource "kubernetes_manifest" "static_unseal_generator" {
  manifest = {
    apiVersion = "generators.external-secrets.io/v1alpha1"
    kind       = "Password"
    metadata = {
      name      = "static-unseal-generator"
      namespace = var.namespace
    }
    spec = {
      length   = 32
      encoding = "hex"
    }
  }
}

resource "kubernetes_manifest" "static_unseal_key_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "static-unseal-key"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "static-unseal-key"
        template = {
          data = {
            "OPENBAO_STATIC_UNSEAL_KEY" = "{{ .password }}"
          }
        }
      }
      dataFrom = [{
        sourceRef = {
          generatorRef = {
            apiVersion = "generators.external-secrets.io/v1alpha1"
            kind       = "Password"
            name       = kubernetes_manifest.static_unseal_generator.object.metadata.name
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "push_static_unseal_key" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.static_unseal_key_sync.object.spec.target.name}"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "1h"
      deletionPolicy  = "None"
      secretStoreRefs = [{
        name = kubernetes_manifest.cluster_store.manifest.metadata.name
        kind = "ClusterSecretStore"
      }]
      selector = {
        secret = {
          name = kubernetes_manifest.static_unseal_key_sync.object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${var.namespace}/infrastructure/${kubernetes_manifest.static_unseal_key_sync.object.spec.target.name}"
            }
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.static_unseal_key_sync]
}
