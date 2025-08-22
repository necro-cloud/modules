resource "kubernetes_deployment" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app       = var.app_name
        component = "pod"
        used-for  = "pgadmin"
      }
    }
    template {
      metadata {
        labels = {
          app       = var.app_name
          component = "pod"
          used-for  = "pgadmin"
        }
      }
      spec {
        container {
          name    = "pgadmin"
          image   = "busybox"
          command = ["sh", "-c", "sleep 7200"]

          env_from {
            secret_ref {
              name = kubernetes_secret.pgadmin_credentials.metadata[0].name
            }
          }

          env {
            name  = "PGADMIN_DISABLE_POSTFIX"
            value = true
          }

          volume_mount {
            name       = "servers-configuration"
            mount_path = "/pgadmin4"
          }
        }


        container {
          name  = "proxy"
          image = "${var.proxy_repository}/${var.proxy_image}:${var.proxy_tag}"

          port {
            container_port = 443
            name           = "https"
          }

          volume_mount {
            name       = "internal-certificate"
            mount_path = "/mnt/ssl"
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx"
          }

          # liveness_probe {
          #   exec {
          #     command = ["curl", "--cacert", "/mnt/crt/ca.crt", "https://localhost:443/health"]
          #   }

          #   initial_delay_seconds = 5
          #   period_seconds        = 30
          # }

          # readiness_probe {
          #   exec {
          #     command = ["curl", "--cacert", "/mnt/crt/ca.crt", "https://localhost:443/health"]
          #   }

          #   initial_delay_seconds = 5
          #   period_seconds        = 30
          # }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_conf.metadata[0].name
          }
        }

        volume {
          name = "servers-configuration"
          config_map {
            name = kubernetes_config_map.pgadmin_servers_configuration.metadata[0].name
          }
        }

        volume {
          name = "internal-certificate"
          secret {
            secret_name = kubernetes_manifest.pgadmin_internal_certificate.manifest.spec.secretName
          }
        }

        volume {
          name = "client-certificates"
          projected {
            sources {
              secret {
                name = kubernetes_manifest.client_keycloak_certificate.manifest.spec.secretName
              }

              dynamic "secret" {
                for_each = kubernetes_manifest.client_certificates
                content {
                  name = secret.value.manifest.spec.secretName
                }
              }
            }
          }
        }

        volume {
          name = "client-passwords"
          projected {
            sources {
              secret {
                name = kubernetes_secret.keycloak_database_credentials.metadata[0].name
              }

              dynamic "secret" {
                for_each = kubernetes_secret.client_database_credentials
                content {
                  name = secret.value.metadata[0].name
                }
              }
            }
          }
        }
      }
    }
  }
}
