resource "kubernetes_deployment" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app         = var.app_name
        component   = "pod"
        used-for    = "pgadmin"
        "pg-access" = true
      }
    }
    template {
      metadata {
        labels = {
          app         = var.app_name
          component   = "pod"
          used-for    = "pgadmin"
          "pg-access" = true
        }
      }
      spec {
        container {
          name  = "pgadmin"
          image = "${var.repository}/${var.image}:${var.tag}"

          env_from {
            secret_ref {
              name = kubernetes_secret.pgadmin_credentials.metadata[0].name
            }
          }

          env {
            name  = "PGADMIN_DISABLE_POSTFIX"
            value = true
          }

          env {
            name  = "PGADMIN_CONFIG_ENABLE_PSQL"
            value = "True"
          }

          volume_mount {
            name       = "servers-configuration"
            mount_path = "/pgadmin4/servers.json"
            sub_path   = "servers.json"
            read_only  = true
          }

          volume_mount {
            name       = "client-passwords"
            mount_path = "/mnt/passwords"
          }

          volume_mount {
            name       = "client-certificates"
            mount_path = "/mnt/certs"
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

          liveness_probe {
            exec {
              command = ["curl", "--cacert", "/mnt/ssl/ca.crt", "https://localhost:443/health"]
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }

          readiness_probe {
            exec {
              command = ["curl", "--cacert", "/mnt/ssl/ca.crt", "https://localhost:443/health"]
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }
        }

        // NGINX Configuration for TLS
        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_conf.metadata[0].name
          }
        }

        // Servers Configuration
        volume {
          name = "servers-configuration"
          config_map {
            name = kubernetes_config_map.pgadmin_servers_configuration.metadata[0].name
          }
        }

        // Internal Certificates for TLS
        volume {
          name = "internal-certificate"
          secret {
            secret_name = kubernetes_manifest.pgadmin_internal_certificate.manifest.spec.secretName
          }
        }

        // PostgreSQL Client Certificates Projected Volume
        volume {
          name = "client-certificates"
          projected {
            sources {
              secret {
                name = kubernetes_manifest.client_keycloak_certificate.manifest.spec.secretName

                items {
                  key  = "ca.crt"
                  path = "keycloak/ca.crt"
                }
                items {
                  key  = "tls.crt"
                  path = "keycloak/tls.crt"
                }
                items {
                  key  = "tls.key"
                  path = "keycloak/tls.key"
                }
              }

              dynamic "secret" {
                for_each = kubernetes_manifest.client_certificates
                content {
                  name = secret.value.manifest.spec.secretName

                  items {
                    key  = "ca.crt"
                    path = "${split("-", secret.value.manifest.spec.secretName)[1]}/ca.crt"
                  }
                  items {
                    key  = "tls.crt"
                    path = "${split("-", secret.value.manifest.spec.secretName)[1]}/tls.crt"
                  }
                  items {
                    key  = "tls.key"
                    path = "${split("-", secret.value.manifest.spec.secretName)[1]}/tls.key"
                  }
                }
              }
            }
          }
        }

        // Client Passwords Projected Volume
        volume {
          name = "client-passwords"
          projected {
            sources {
              secret {
                name = kubernetes_secret.keycloak_database_credentials.metadata[0].name
                items {
                  key  = "password"
                  path = "keycloak/password"
                }
              }

              dynamic "secret" {
                for_each = kubernetes_secret.client_database_credentials
                content {
                  name = secret.value.metadata[0].name
                  items {
                    key  = "password"
                    path = "${split("-", secret.value.metadata[0].name)[1]}/password"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
