// Kubernetes Job which will configure Garage Storage Solution
// by setting up the cluster nodes, buckets, users and permissions
resource "kubernetes_job" "configurator" {
  metadata {
    name      = "garage-configurator"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "job"
    }
  }

  spec {
    completions                = 1
    ttl_seconds_after_finished = 5 * 60
    template {
      metadata {
        labels = {
          app       = var.app_name
          component = "pod"
          created-by : "job"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.garage_configurator_service_account.metadata[0].name
        container {
          name  = "garage-configurator"
          image = "${var.configurator_repository}/${var.configurator_image}:${var.configurator_tag}"

          security_context {
            run_as_non_root = true
            run_as_group    = 1001
            run_as_user     = 1001
          }

          env {
            name  = "CONFIGURATOR_JSON"
            value = "/mnt/config/configurator.json"
          }

          env {
            name = "GARAGE_ADMIN_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.admin_password.metadata[0].name
                key  = "GARAGE_ADMIN_TOKEN"
              }
            }
          }

          env {
            name  = "NODE_EXTRA_CA_CERTS"
            value = "/mnt/crts/ca.crt"
          }

          env {
            name  = "EXECUTION_MODE"
            value = "cluster"
          }

          volume_mount {
            name       = "garage-ca"
            mount_path = "/mnt/crts/"
          }

          volume_mount {
            name       = "garage-config"
            mount_path = "/mnt/config"
          }
        }

        volume {
          name = "garage-ca"
          secret {
            secret_name = kubernetes_manifest.internal_certificate.manifest.metadata.name
          }
        }

        volume {
          name = "garage-config"
          config_map {
            name = kubernetes_config_map.configurator-options.metadata[0].name
          }
        }
      }

    }
  }

  depends_on = [kubernetes_stateful_set.statefulset]
}
