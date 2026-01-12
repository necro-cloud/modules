// Database Configuration for Ferret
resource "kubernetes_manifest" "ferret_database" {
  manifest = {
    "apiVersion" : "postgresql.cnpg.io/v1"
    "kind" : "Database"
    "metadata" = {
      "name"      = "ferret"
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "cluster"
      }
    }

    "spec" = {
      "databaseReclaimPolicy" : "delete"
      "name" : "ferret"
      "owner" : "ferret"
      "cluster" = {
        "name" = kubernetes_manifest.cluster.manifest.metadata.name
      }
      "extensions" = [
        {
          "name" = "vector"
          "ensure" = "present"
        },
        {
          "name" = "pg_cron"
          "ensure" = "present"
        },
        {
          "name" = "documentdb_core"
          "ensure" = "present"
        },
        {
          "name" = "documentdb"
          "ensure" = "present"
        }
      ]
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
