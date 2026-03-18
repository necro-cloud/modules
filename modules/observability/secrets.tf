// Password Generator for generating random passwords
resource "kubernetes_manifest" "password_generator" {
  manifest = {
    apiVersion = "generators.external-secrets.io/v1alpha1"
    kind       = "Password"
    metadata = {
      name      = "password-generator"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      length  = 20
      digits  = 5
      symbols = 0
      noUpper = true
    }
  }
}

// UI credentials configuration for Grafana
resource "kubernetes_manifest" "grafana_credentials_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "grafana-credentials"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "grafana-credentials"
        template = {
          data = {
            username = "observability.admin"
            password = "{{ .password }}"
          }
        }
      }
      dataFrom = [{
        sourceRef = {
          generatorRef = {
            apiVersion = "generators.external-secrets.io/v1alpha1"
            kind       = "Password"
            name       = kubernetes_manifest.password_generator.object.metadata.name
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "push_grafana_credentials" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.grafana_credentials_sync.object.spec.target.name}"
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
          name = kubernetes_manifest.grafana_credentials_sync.object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/credentials/ui/${kubernetes_manifest.grafana_credentials_sync.object.spec.target.name}"
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.grafana_credentials_sync]
}
