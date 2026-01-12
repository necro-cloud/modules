// CloudNative PG Cluster
resource "kubernetes_manifest" "cluster" {
  manifest = {
    "apiVersion" = "postgresql.cnpg.io/v1"
    "kind"       = "Cluster"
    "metadata" = {
      "labels" = {
        "app"       = var.app_name
        "component" = "cluster"
      }
      "name"      = var.cluster_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
    }
    "spec" = {
      "inheritedMetadata" = {
        "labels" = {
          "garage-access" = true
        }
      }
      "postgresUID" = 999
      "postgresGID" = 999
      "enableSuperuserAccess" = true
      "topologySpreadConstraints" = [
        {
          "maxSkew"           = 1
          "topologyKey"       = "kubernetes.io/hostname"
          "whenUnsatisfiable" = "DoNotSchedule"
          "labelSelector" = {
            "matchLabels" = {
              "cnpg.io/cluster" = var.cluster_name
            }
          }
        }
      ]
      "imageCatalogRef" = {
        "apiGroup" = "postgresql.cnpg.io",
        "kind"     = "ClusterImageCatalog"
        "name"     = kubernetes_manifest.ferret_cluster_image_catalog.manifest.metadata.name
        "major"    = var.cluster_postgresql_version
      }
      "description"           = "PostgreSQL Cluster for storing relational data"
      "enableSuperuserAccess" = true
      "instances"             = var.cluster_size
      // Required postgresql configuration for DocumentDB
      "postgresql" = {
        "shared_preload_libraries" = [
          "pg_cron",
          "pg_documentdb_core",
          "pg_documentdb",
        ]
        "parameters" = {
          "search_path" = "\"$user\", public, documentdb_api, documentdb_core"
          "cron.database_name" = "postgres"
        }
      }
      "bootstrap" = {
        "initdb" = {
          "postInitSQL" = [
            "CREATE EXTENSION IF NOT EXISTS documentdb CASCADE;"
          ]
        }
      }
      "managed" = {
        "roles" = concat([
          {
            "bypassrls"       = false
            "comment"         = "ferret user for postgresql"
            "connectionLimit" = -1
            "createdb"        = true
            "createrole"      = true
            "ensure"          = "present"
            "inherit"         = true
            "login"           = true
            "name"            = "ferret"
            "passwordSecret" = {
              "name" = kubernetes_secret.ferret_database_credentials.metadata[0].name
            }
            "replication" = false
            "superuser"   = false
          },
        ], local.managed_roles)
      }
      "primaryUpdateStrategy" = "unsupervised"
      "resources" = {
        "limits" = {
          "cpu"    = "500m"
          "memory" = "1Gi"
        }
        "requests" = {
          "cpu"    = "500m"
          "memory" = "1Gi"
        }
      }
      "startDelay" = 300
      "storage" = {
        "pvcTemplate" = {
          "accessModes" = [
            "ReadWriteOnce",
          ]
          "resources" = {
            "requests" = {
              "storage" = "5Gi"
            }
          }
          "storageClassName" = "local-path"
          "volumeMode"       = "Filesystem"
        }
        "size" = "5Gi"
      }
      "certificates" = {
        "serverTLSSecret"      = kubernetes_manifest.server_certificate.manifest.spec.secretName
        "serverCASecret"       = kubernetes_manifest.server_certificate_authority.manifest.spec.secretName
        "clientCASecret"       = kubernetes_manifest.client_certificate_authority.manifest.spec.secretName
        "replicationTLSSecret" = kubernetes_manifest.client_streaming_replica_certificate.manifest.spec.secretName
      }
      "plugins" = [
        {
          "name"          = "barman-cloud.cloudnative-pg.io"
          "isWALArchiver" = true
          "parameters" = {
            "barmanObjectName" = kubernetes_manifest.barman_object_store.manifest.metadata.name
          }
        }
      ]
    }
  }

  // Fields to ignore changes for
  computed_fields = ["spec.managed.roles[0].replication", "spec.managed.roles[0].superuser", "spec.managed.roles[0].bypassrls", "spec.managed.roles[1].bypassrls", "spec.managed.roles[1].superuser", "spec.managed.roles[1].replication", "spec.postgresql.parameters"]

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
