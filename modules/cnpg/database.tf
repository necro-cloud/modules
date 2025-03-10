// Database Configuration for Keycloak
resource "kubernetes_manifest" "keycloak_database" {
  manifest = {
    "apiVersion" : "postgresql.cnpg.io/v1"
    "kind" : "Database"
    "metadata" = {
      "name"      = "keycloak"
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "cluster"
      }
    }

    "spec" = {
      "databaseReclaimPolicy" : "delete"
      "name" : "keycloak"
      "owner" : "keycloak"
      "cluster" = {
        "name" = kubernetes_manifest.cluster.manifest.metadata.name
      }
    }
  }

  wait {
    fields = {
      "status.applied" = "true"
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

// Database Configuration for all clients
resource "kubernetes_manifest" "databases" {
  count = length(var.clients)
  manifest = {
    "apiVersion" : "postgresql.cnpg.io/v1"
    "kind" : "Database"
    "metadata" = {
      "name"      = var.clients[count.index].database
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "cluster"
      }
    }

    "spec" = {
      "databaseReclaimPolicy" : "delete"
      "name" : var.clients[count.index].database
      "owner" : var.clients[count.index].user
      "cluster" = {
        "name" = kubernetes_manifest.cluster.manifest.metadata.name
      }
    }
  }

  wait {
    fields = {
      "status.applied" = "true"
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}
