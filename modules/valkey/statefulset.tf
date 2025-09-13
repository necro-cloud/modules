resource "kubernetes_stateful_set" "valkey_cluster" {
  metadata {
    name      = "valkey-cluster"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "statefulset"
    }
  }

  spec {
    service_name = kubernetes_service.headless_service.metadata[0].name
    replicas     = var.replicas

    selector {
      match_labels = {
        app       = var.app_name
        "part-of" = "valkey-cluster"
      }
    }

    template {
      metadata {
        labels = {
          app       = var.app_name
          "part-of" = "valkey-cluster"
        }
      }

      spec {
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "worker"
          when_unsatisfiable = "DoNotSchedule"
          label_selector {
            match_labels = {
              app       = var.app_name
              "part-of" = "valkey-cluster"
            }
          }
        }
        container {
          name  = "valkey"
          image = "${var.repository}/${var.image}:${var.tag}"

          command = ["sh", "-c"]
          args = [
            <<EOF
              sed "s|VALKEY_PASSWORD|$VALKEY_PASSWORD|g" /etc/valkey/conf_template/valkey.conf > /etc/valkey/conf/valkey.conf

              if [ "$(hostname)" = "valkey-cluster-0" ]; then
                valkey-server /etc/valkey/conf/valkey.conf --requirepass "$(VALKEY_PASSWORD)"
              else
                valkey-server /etc/valkey/conf/valkey.conf --requirepass "$(VALKEY_PASSWORD)" --replicaof valkey-primary-service 6379
              fi
            EOF
          ]

          env_from {
            secret_ref {
              name = kubernetes_secret.valkey_password.metadata[0].name
            }
          }

          port {
            container_port = 6379
            name           = "valkey"
          }

          resources {
            requests = {
              "cpu"    = "250m"
              "memory" = "512Mi"
            }
            limits = {
              "cpu"    = "1"
              "memory" = "1Gi"
            }
          }

          readiness_probe {
            exec {
              command = ["sh", "-c", "valkey-cli --tls --cacert /etc/valkey/tls/ca.crt --cert /etc/valkey/tls/tls.crt --key /etc/valkey/tls/tls.key --pass $VALKEY_PASSWORD PING | grep PONG"]
            }

            initial_delay_seconds = 20
            period_seconds        = 10
            timeout_seconds       = 10
            failure_threshold     = 3
          }

          liveness_probe {
            exec {
              command = ["sh", "-c", "valkey-cli --tls --cacert /etc/valkey/tls/ca.crt --cert /etc/valkey/tls/tls.crt --key /etc/valkey/tls/tls.key --pass $VALKEY_PASSWORD PING | grep PONG"]
            }

            initial_delay_seconds = 20
            period_seconds        = 10
            timeout_seconds       = 10
            failure_threshold     = 3
          }

          volume_mount {
            name       = "template-configuration"
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

          volume_mount {
            name       = "valkey-data"
            mount_path = "/data"
          }
        }

        volume {
          name = "template-configuration"
          config_map {
            name = kubernetes_config_map.valkey_conf.metadata[0].name
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

    volume_claim_template {
      metadata {
        name = "valkey-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }
}
