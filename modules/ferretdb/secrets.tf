// Garage Credentials for storing PostgreSQL PITR Backups
resource "kubernetes_manifest" "garage_configuration_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = var.garage_configuration
      namespace = kubernetes_namespace.namespace.metadata[0].name
      labels = {
        app       = var.app_name
        component = "secret"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = var.cluster_secret_store_name
        kind = "ClusterSecretStore"
      }
      target = {
        name = var.garage_configuration
      }
      dataFrom = [
        {
          extract = {
            key = "${var.garage_namespace}/access-key/${var.garage_configuration}"
          }
        }
      ]
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
}

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

// Database credentials configuration for Ferret
resource "kubernetes_manifest" "ferret_database_credentials_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "credentials-ferret"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "credentials-ferret"
        template = {
          type = "kubernetes.io/basic-auth"
          data = {
            username = "ferret"
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

resource "kubernetes_manifest" "push_ferret_database_credentials" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.keycloak_database_credentials_sync.object.spec.target.name}"
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
          name = kubernetes_manifest.keycloak_database_credentials_sync.object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/credentials/${kubernetes_manifest.ferret_database_credentials_sync.object.spec.target.name}"
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.ferret_database_credentials_sync]
}


// Database credentials configuration for all clients
resource "kubernetes_manifest" "client_database_credentials_sync" {
  count   = length(var.clients)
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "credentials-${var.clients[count.index].user}"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "credentials-${var.clients[count.index].user}"
        template = {
          type = "kubernetes.io/basic-auth"
          data = {
            username = var.clients[count.index].user
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

resource "kubernetes_manifest" "push_client_database_credentials" {
  count   = length(var.clients)
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.client_database_credentials_sync[count.index].object.spec.target.name}"
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
          name = kubernetes_manifest.client_database_credentials_sync[count.index].object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/credentials/${kubernetes_manifest.client_database_credentials_sync[count.index].object.spec.target.name}"
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.client_database_credentials_sync]
}

// UI credentials configuration for MongoExpress
resource "kubernetes_manifest" "mongo_express_credentials_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "mongo-express-credentials"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "mongo-express-credentials"
        template = {
          data = {
            username = "ferret"
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

resource "kubernetes_manifest" "push_mongo_express_credentials" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.mongo_express_credentials_sync.object.spec.target.name}"
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
          name = kubernetes_manifest.mongo_express_credentials_sync.object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/credentials/ui/${kubernetes_manifest.mongo_express_credentials_sync.object.spec.target.name}"
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.mongo_express_credentials_sync]
}
