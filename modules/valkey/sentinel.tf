resource "kubernetes_deployment" "sentinel" {
  metadata {
    name      = "valkey-sentinel"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "deployment"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app       = var.app_name
        "part-of" = "valkey-sentinel"
      }
    }

    template {
      metadata {
        labels = {
          app       = var.app_name
          "part-of" = "valkey-sentinel"
        }
      }

      spec {
        container {
          name  = "sentinel"
          image = "valkey/valkey:8.1.3"

          command = ["sh", "-c"]
          args = [
            <<EOF
              sed -e "s|SENTINEL_IP|$SENTINEL_ANNOUNCE_IP|g" -e "s|VALKEY_PASSWORD|$VALKEY_PASSWORD|g" /etc/valkey/conf_template/sentinel.conf > /etc/valkey/conf/sentinel.conf
              valkey-sentinel /etc/valkey/conf/sentinel.conf
            EOF
          ]

          env_from {
            secret_ref {
              name = kubernetes_secret.valkey_password.metadata[0].name
            }
          }

          env {
            name = "SENTINEL_ANNOUNCE_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          port {
            container_port = 26379
            name           = "sentinel"
          }

          volume_mount {
            name       = "configuration-template"
            mount_path = "/etc/valkey/conf_template"
          }

          volume_mount {
            name       = "configuration"
            mount_path = "/etc/valkey/conf"
          }

          volume_mount {
            name       = "certificates"
            mount_path = "/etc/valkey/tls"
          }

        }

        container {
          name  = "stunnel"
          image = "alpine:3.22.1"

          command = ["sh", "-c"]
          args = [
            <<EOF
              apk add --no-cache stunnel
              stunnel /etc/stunnel/stunnel.conf
            EOF
          ]

          volume_mount {
            name       = "stunnel-configuration"
            mount_path = "/etc/stunnel"
          }

          volume_mount {
            name       = "certificates"
            mount_path = "/etc/valkey/tls"
          }
        }

        volume {
          name = "configuration-template"
          config_map {
            name = kubernetes_config_map.sentinel_conf.metadata[0].name
          }
        }

        volume {
          name = "stunnel-configuration"
          config_map {
            name = kubernetes_config_map.sentinel_stunnel_conf.metadata[0].name
          }
        }

        volume {
          name = "configuration"
          empty_dir {}
        }

        volume {
          name = "certificates"
          secret {
            secret_name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
          }
        }
      }
    }
  }

  depends_on = [kubernetes_stateful_set.valkey_cluster]
}
