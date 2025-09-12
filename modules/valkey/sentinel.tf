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
              sed "s|VALKEY_PASSWORD|$VALKEY_PASSWORD|g" /etc/valkey/conf_template/sentinel.conf > /etc/valkey/conf/sentinel.conf

              echo "Waiting for primary service (valkey-primary-service) to be fully connectable..."
              until valkey-cli --tls --cacert /etc/valkey/tls/ca.crt --cert /etc/valkey/tls/tls.crt --key /etc/valkey/tls/tls.key --pass $VALKEY_PASSWORD -h valkey-primary-service -p 6379 PING > /dev/null 2>&1; do
                echo "Primary service not yet connectable, sleeping for 2 seconds..."
                sleep 2
              done
              echo "Primary service is connectable. Starting Sentinel..."

              valkey-sentinel /etc/valkey/conf/sentinel.conf
            EOF
          ]

          env_from {
            secret_ref {
              name = kubernetes_secret.valkey_password.metadata[0].name
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

        volume {
          name = "configuration-template"
          config_map {
            name = kubernetes_config_map.sentinel_conf.metadata[0].name
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
