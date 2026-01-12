resource "kubernetes_manifest" "barman_object_store" {
  manifest = {
    "apiVersion" = "barmancloud.cnpg.io/v1"
    "kind"       = "ObjectStore"
    "metadata" = {
      "labels" = {
        "app"       = var.app_name
        "component" = "objectstore"
      }
      "name"      = "${var.cluster_name}-objectstore"
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
    }
    "spec" = {
      "configuration" = {
        "data" = {
          "additionalCommandArgs" = [
            "--min-chunk-size=5MB",
            "--read-timeout=60",
            "-vv",
          ]
        }
        "destinationPath" = "s3://${var.backup_bucket_name}/"
        "endpointCA" = {
          "key"  = "ca.crt"
          "name" = kubernetes_secret.garage_certificate_authority.metadata[0].name
        }
        "endpointURL" = "https://garage-service.${var.garage_namespace}.svc.cluster.local:3940"
        "s3Credentials" = {
          "accessKeyId" = {
            "key"  = "ACCESS_KEY_ID"
            "name" = kubernetes_secret.garage_configuration.metadata[0].name
          }
          "secretAccessKey" = {
            "key"  = "SECRET_ACCESS_KEY"
            "name" = kubernetes_secret.garage_configuration.metadata[0].name
          }
          "region" = {
            "key"  = "S3_REGION"
            "name" = kubernetes_secret.garage_configuration.metadata[0].name
          }
        }
        "wal" = {
          "compression" = "gzip"
        }
      }
    }
  }
}
