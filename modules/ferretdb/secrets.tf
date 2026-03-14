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

// Database credentials configuration for Ferret
resource "random_password" "ferret_password" {
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "ferret_database_credentials" {
  metadata {
    name      = "credentials-ferret"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    "username" = "ferret"
    "password" = random_password.ferret_password.result
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

// UI credentials configuration for MongoExpress
resource "random_password" "ui_password" {
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "ui_credentials" {
  metadata {
    name      = "ui-ferret"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    "username" = "ferret"
    "password" = random_password.ferret_password.result
  }

  type = "kubernetes.io/basic-auth"
}
