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

// Credentials configuration for Valkey
resource "kubernetes_manifest" "valkey_credentials_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "valkey-credentials"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "valkey-credentials"
        template = {
          data = {
            VALKEY_PASSWORD = "{{ .password }}"
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

resource "kubernetes_manifest" "push_valkey_credentials" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.valkey_credentials_sync.object.spec.target.name}"
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
          name = kubernetes_manifest.valkey_credentials_sync.object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/credentials/${kubernetes_manifest.valkey_credentials_sync.object.spec.target.name}"
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.valkey_credentials_sync]
}

// Credentials configuration for Redis Commander
resource "kubernetes_manifest" "ui_credentials_sync" {
  count = var.enable_ui ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "ui-credentials"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "ui-credentials"
        template = {
          data = {
            HTTP_USER     = "valkey.admin"
            HTTP_PASSWORD = "{{ .password }}"
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

resource "kubernetes_manifest" "push_ui_credentials" {
  count = var.enable_ui ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.ui_credentials_sync[0].object.spec.target.name}"
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
          name = kubernetes_manifest.ui_credentials_sync[0].object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/credentials/ui/${kubernetes_manifest.ui_credentials_sync[0].object.spec.target.name}"
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.ui_credentials_sync]
}

resource "kubernetes_secret" "redis_commander_configuration" {
  count = var.enable_ui ? 1 : 0
  metadata {
    name = "redis-commander-configuration"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = var.enable_internal_tls_certificates ? {
    "REDIS_HOST"             = "${kubernetes_service.primary_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
    "REDIS_PORT"             = 6379
    "REDIS_TLS"              = true
    "REDIS_TLS_CA_CERT_FILE" = "/mnt/certs/ca.crt"
    "REDIS_TLS_CERT_FILE"    = "/mnt/certs/tls.crt"
    "REDIS_TLS_KEY_FILE"     = "/mnt/certs/tls.key"
    "REDIS_TLS_SERVER_NAME"  = "${kubernetes_service.primary_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
  } : {
    "REDIS_HOST"             = "${kubernetes_service.primary_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
    "REDIS_PORT"             = 6379
    "REDIS_TLS"              = false
  }
}
