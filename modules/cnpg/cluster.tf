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
      "imageCatalogRef" = {
        "apiGroup" = "postgresql.cnpg.io",
        "kind"     = "ClusterImageCatalog"
        "name"     = kubernetes_manifest.cluster_image_catalog.manifest.metadata.name
        "major"    = var.cluster_postgresql_version
      }
      "description"           = "PostgreSQL Cluster for storing relational data"
      "enableSuperuserAccess" = true
      "instances"             = var.cluster_size
      "managed" = {
        "roles" = concat([
          {
            "bypassrls"       = false
            "comment"         = "keycloak user for postgresql"
            "connectionLimit" = -1
            "createdb"        = true
            "createrole"      = true
            "ensure"          = "present"
            "inherit"         = true
            "login"           = true
            "name"            = "keycloak"
            "passwordSecret" = {
              "name" = kubernetes_secret.keycloak_database_credentials.metadata[0].name
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
              "storage" = "1Gi"
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
  computed_fields = ["spec.managed.roles[0].replication", "spec.managed.roles[0].superuser", "spec.managed.roles[0].bypassrls", "spec.managed.roles[1].bypassrls", "spec.managed.roles[1].superuser", "spec.managed.roles[1].replication"]

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
