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

// SSO Client Secret Generation
resource "kubernetes_manifest" "sso_client_secret_generator" {
  count = var.enable_sso ? 1 : 0
  manifest = {
    apiVersion = "generators.external-secrets.io/v1alpha1"
    kind       = "Password"
    metadata = {
      name      = "sso-client-secret-generator"
      namespace = var.namespace
    }
    spec = {
      length  = 20
      digits  = 10
      symbols = 0
      noUpper = true
    }
  }
}

resource "kubernetes_manifest" "sso_client_secret_sync" {
  count = var.enable_sso ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "sso-client-secret"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "sso-client-secret"
        template = {
          data = {
            "SSO_CLIENT_KEY" = "{{ .password }}"
          }
        }
      }
      dataFrom = [{
        sourceRef = {
          generatorRef = {
            apiVersion = "generators.external-secrets.io/v1alpha1"
            kind       = "Password"
            name       = kubernetes_manifest.sso_client_secret_generator[0].object.metadata.name
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "push_sso_client_secret" {
  count = var.enable_sso ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.sso_client_secret_sync[0].object.spec.target.name}"
      namespace = var.namespace
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
          name = kubernetes_manifest.sso_client_secret_sync[0].object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "sso/${kubernetes_namespace.namespace.metadata[0].name}/${kubernetes_manifest.sso_client_secret_sync[0].object.spec.target.name}"
            }
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.sso_client_secret_sync]
}
