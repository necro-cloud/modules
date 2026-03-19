// Database Credentials to connect to the PostgreSQL Database
resource "kubernetes_manifest" "database_credentials_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = var.database_credentials
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
        name = var.database_credentials
        template = {
          type = "Opaque"
          engineVersion = "v2"
        }
      }
      dataFrom = [{
        extract = {
          key = "${var.postgres_namespace}/credentials/${var.database_credentials}"
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

// Keycloak credentials configuration
resource "kubernetes_manifest" "keycloak_credentials_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "keycloak-credentials"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "keycloak-credentials"
        template = {
          data = {
            KC_BOOTSTRAP_ADMIN_USERNAME = "keycloak.admin"
            KC_BOOTSTRAP_ADMIN_PASSWORD = "{{ .password }}"
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

resource "kubernetes_manifest" "push_keycloak_credentials" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.keycloak_credentials_sync.object.spec.target.name}"
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
          name = kubernetes_manifest.keycloak_credentials_sync.object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/credentials/ui/${kubernetes_manifest.keycloak_credentials_sync.object.spec.target.name}"
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.keycloak_credentials_sync]
}

# Keycloak Realm Configuration
resource "kubernetes_manifest" "realm_secrets_sync" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "realm-secrets"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "0"
      target = {
        name = "realm-secrets"
        template = {
          data = {
            DISPLAY_NAME               = var.realm_settings["display_name"]
            APPLICATION_NAME           = var.realm_settings["application_name"]
            BASE_URL                   = var.realm_settings["base_url"]
            VALID_LOGIN_REDIRECT_PATH  = var.realm_settings["valid_login_redirect_path"]
            VALID_LOGOUT_REDIRECT_PATH = var.realm_settings["valid_logout_redirect_path"]
            SMTP_HOST                  = var.realm_settings["smtp_host"]
            SMTP_PORT                  = var.realm_settings["smtp_port"]
            SMTP_MAIL                  = var.realm_settings["smtp_mail"]
            SMTP_USERNAME              = var.realm_settings["smtp_username"]
            SMTP_PASSWORD              = var.realm_settings["smtp_password"]
            TESTER_SECRET              = "{{ .password }}"
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

resource "kubernetes_manifest" "push_realm_secrets" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-${kubernetes_manifest.realm_secrets_sync.object.spec.target.name}"
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
          name = kubernetes_manifest.realm_secrets_sync.object.spec.target.name
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/infrastructure/${kubernetes_manifest.realm_secrets_sync.object.spec.target.name}"
            }
          }
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.realm_secrets_sync]
}
