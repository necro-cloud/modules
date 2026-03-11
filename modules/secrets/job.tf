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
        service_account_name = kubernetes_service_account.configurator.metadata[0].name
        restart_policy       = "OnFailure"
        
        container {
          name    = "configurator"
          image   = "quay.io/openbao/openbao:2.5.1"
          command = ["/bin/sh", "/scripts/configurator.sh"]
          
          volume_mount {
            name       = "scripts"
            mount_path = "/scripts"
          }
          
          volume_mount {
            name       = "tls"
            mount_path = "/openbao/userconfig/${kubernetes_manifest.internal_certificate.manifest.spec.secretName}"
            read_only  = true
          }
        }

        volume {
          name = "scripts"
          config_map {
            name = kubernetes_config_map.configurator_script.metadata[0].name
            default_mode = "0755"
          }
        }

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
