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

// Database credentials configuration for Keycloak
resource "random_password" "keycloak_password" {
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "keycloak_database_credentials" {
  metadata {
    name      = "credentials-keycloak"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = "keycloak"
    }
  }

  data = {
    "username" = "keycloak"
    "password" = random_password.keycloak_password.result
  }

  type = "kubernetes.io/basic-auth"
}

// Database credentials configuration for all clients
resource "random_password" "client_password" {
  count   = length(var.clients)
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "client_database_credentials" {
  count = length(var.clients)
  metadata {
    name      = "credentials-${var.clients[count.index].user}"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.clients[count.index].namespace
    }
  }

  data = {
    "username" = var.clients[count.index].user
    "password" = random_password.client_password[count.index].result
  }

  type = "kubernetes.io/basic-auth"
}


resource "random_password" "pgadmin_password" {
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "pgadmin_credentials" {
  metadata {
    name      = "pgadmin-credentials"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    "PGADMIN_DEFAULT_EMAIL"    = "noreply@${var.organization_name}.com"
    "PGADMIN_DEFAULT_PASSWORD" = random_password.pgadmin_password.result
  }

  type = "Opaque"
}
