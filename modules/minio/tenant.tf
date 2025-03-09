locals {
  users   = [for secret in concat(kubernetes_secret.user_configuration, [kubernetes_secret.postgres_user_configuration]) : { "name" : secret.metadata[0].name }]
  buckets = [for bucket in concat(var.buckets, ["postgres"]) : { "name" : bucket }]
}

resource "kubernetes_manifest" "minio_tenant" {
  manifest = {
    "apiVersion" = "minio.min.io/v2"
    "kind"       = "Tenant"
    "metadata" = {
      "annotations" = {
        "prometheus.io/path"   = "/minio/v2/metrics/cluster"
        "prometheus.io/port"   = "9000"
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "app"       = var.app_name
        "component" = "tenant"
      }
      "name"      = "minio"
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
    }
    "spec" = {
      "buckets" = local.buckets
      "configuration" = {
        "name" = kubernetes_secret.storage_configuration.metadata[0].name
      }
      "externalCertSecret" = [
        {
          "name" = kubernetes_manifest.internal_certificate.manifest.metadata.name
          "type" = "cert-manager.io/v1"
        },
      ]
      "image"               = "quay.io/minio/minio:RELEASE.2025-02-28T09-55-16Z"
      "mountPath"           = "/export"
      "podManagementPolicy" = "Parallel"
      "pools" = [
        {
          "containerSecurityContext" = {
            "allowPrivilegeEscalation" = false
            "capabilities" = {
              "drop" = [
                "ALL",
              ]
            }
            "runAsGroup"   = 1000
            "runAsNonRoot" = true
            "runAsUser"    = 1000
            "seccompProfile" = {
              "type" = "RuntimeDefault"
            }
          }
          "name" = "storage"
          "resources" = {
            "limits" = {
              "cpu"    = "500m"
              "memory" = "500Mi"
            }
            "requests" = {
              "cpu"    = "100m"
              "memory" = "100Mi"
            }
          }
          "securityContext" = {
            "fsGroup"             = 1000
            "fsGroupChangePolicy" = "OnRootMismatch"
            "runAsGroup"          = 1000
            "runAsNonRoot"        = true
            "runAsUser"           = 1000
          }
          "servers" = 4
          "volumeClaimTemplate" = {
            "apiVersion" = "v1"
            "kind"       = "persistentvolumeclaims"
            "metadata" = {
              "namespace" = "${var.namespace}"
              "labels" = {
                "app"       = "minio"
                "component" = "pvc"
              }
            }
            "spec" = {
              "accessModes" = [
                "ReadWriteOnce",
              ]
              "resources" = {
                "requests" = {
                  "storage" = "5Gi"
                }
              }
              "storageClassName" = "local-path"
            }
          }
          "volumesPerServer" = 1
        },
      ]
      "priorityClassName" = ""
      "requestAutoCert"   = false
      "serviceMetadata" = {
        "consoleServiceLabels" = {
          "app"       = var.app_name
          "component" = "service"
        }
        "minioServiceLabels" = {
          "app"       = var.app_name
          "component" = "service"
        }
      }
      "subPath" = ""
      "users"   = local.users
    }
  }
}
