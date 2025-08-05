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
      "backup" = {
        "barmanObjectStore" = {
          "data" = {
            "additionalCommandArgs" = [
              "--min-chunk-size=5MB",
              "--read-timeout=60",
              "-vv",
            ]
          }
          "destinationPath" = "s3://postgresql/"
          "endpointCA" = {
            "key"  = "ca.crt"
            "name" = kubernetes_secret.garage_certificate_authority.metadata[0].name
          }
          "endpointURL" = "https://garage-service.garage.svc.cluster.local:3940"
          "s3Credentials" = {
            "accessKeyId" = {
              "key"  = "ACCESS_KEY_ID"
              "name" = kubernetes_secret.postgres_user_minio_configuration.metadata[0].name
            }
            "secretAccessKey" = {
              "key"  = "SECRET_ACESS_KEY"
              "name" = kubernetes_secret.postgres_user_minio_configuration.metadata[0].name
            }
            "region" = {
              "key"  = "S3_REGION"
              "name" = kubernetes_secret.postgres_user_minio_configuration.metadata[0].name
            }
          }
          "wal" = {
            "compression" = "gzip"
          }
        }
        "volumeSnapshot" = {
          "className" = "csi-hostpath-snapclass"
        }
      }
      "description"           = "PostgreSQL Cluster for storing relational data"
      "enableSuperuserAccess" = true
      "imageName"             = "ghcr.io/cloudnative-pg/postgresql:16.2"
      "instances"             = 2
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
