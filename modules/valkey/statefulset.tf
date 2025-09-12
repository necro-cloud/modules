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
    replicas     = 3

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
        container {
          name  = "valkey"
          image = "valkey/valkey:8.1.3"

          command = ["sh", "-c"]
          args = [
            <<EOF
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
          name = "configuration"
          config_map {
            name = kubernetes_config_map.valkey_conf.metadata[0].name
          }
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
