// Configurator Job for the OpenBao Cluster
resource "kubernetes_job" "configurator" {
  metadata {
    name      = "openbao-configurator"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "job"
    }
  }
  spec {
    completions = 1
    template {
      metadata {
        labels = {
          app       = var.app_name
          component = "pod"
          created-by : "configurator"
        }
      }
      spec {

        // Service Account to be used for the configurator job
        service_account_name = kubernetes_service_account.configurator.metadata[0].name
        restart_policy       = "OnFailure"
        
        container {
          name    = "configurator"
          image   = "${var.configurator_repository}/${var.configurator_image}:${var.configurator_tag}"
          command = ["/bin/sh", "/scripts/configurator.sh"]

          // Load the configurator script as a volume
          volume_mount {
            name       = "scripts"
            mount_path = "/scripts"
          }

          // Load the TLS certificates used by the cluster as a volume
          volume_mount {
            name       = "tls"
            mount_path = "/openbao/userconfig/${kubernetes_manifest.internal_certificate.manifest.spec.secretName}"
            read_only  = true
          }
        }

        // Volume for the configurator script
        volume {
          name = "scripts"
          config_map {
            name = kubernetes_config_map.configurator_script.metadata[0].name
            default_mode = "0755"
          }
        }

        // Volume for the TLS certificates used by the cluster
        volume {
          name = "tls"
          secret {
            secret_name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
          }
        }
      }
    }
  }
  
  # Ensure OpenBao is fully up before running
  depends_on = [helm_release.openbao, kubernetes_manifest.internal_certificate]
}
