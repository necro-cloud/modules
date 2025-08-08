// Garage Cluster StatefulSet Deployment
resource "kubernetes_stateful_set" "statefulset" {
  metadata {
    name      = var.garage_cluster_name
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "statefulset"
    }
  }

  spec {
    selector {
      match_labels = {
        app       = var.app_name
        component = "pod"
        part_of   = "statefulset"
      }
    }

    replicas = var.cluster_nodes

    service_name = kubernetes_service.garage-headless.metadata[0].name

    template {
      metadata {
        labels = {
          app       = var.app_name
          component = "pod"
          part_of   = "statefulset"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.garage_service_account.metadata[0].name

        security_context {
          fs_group        = 1000
          run_as_group    = 1000
          run_as_non_root = true
          run_as_user     = 1000
        }

        container {
          name  = "garage"
          image = "dxflrs/amd64_garage:v2.0.0"

          env_from {
            secret_ref {
              name = kubernetes_secret.admin_password.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.rpc_secret.metadata[0].name
            }
          }

          port {
            container_port = 3900
            name           = "api"
          }

          port {
            container_port = 3902
            name           = "web"
          }

          port {
            container_port = 3903
            name           = "admin"
          }

          volume_mount {
            name       = "garage-meta"
            mount_path = "/mnt/meta"
          }

          volume_mount {
            name       = "garage-data"
            mount_path = "/mnt/data"
          }

          volume_mount {
            name       = "garage-config"
            mount_path = "/etc/garage.toml"
            sub_path   = "garage.toml"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "admin"
            }
            initial_delay_seconds = 5
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "admin"
            }
            initial_delay_seconds = 5
            period_seconds        = 30
          }
        }

        container {
          name  = "proxy"
          image = "nginx:1.29.0"

          port {
            container_port = 3940
            name           = "proxy-api"
          }

          port {
            container_port = 3942
            name           = "proxy-web"
          }

          port {
            container_port = 3943
            name           = "proxy-admin"
          }

          volume_mount {
            name       = "certificates"
            mount_path = "/mnt/crt"
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx"
          }

          liveness_probe {
            exec {
              command = ["curl", "--cacert", "/mnt/crt/ca.crt", "https://localhost:3943/health"]
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }

          readiness_probe {
            exec {
              command = ["curl", "--cacert", "/mnt/crt/ca.crt", "https://localhost:3943/health"]
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }
        }

        volume {
          name = "garage-config"
          config_map {
            name         = kubernetes_config_map.garage_config.metadata[0].name
            default_mode = "0420"
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name         = kubernetes_config_map.nginx_config.metadata[0].name
            default_mode = "0420"
          }
        }

        volume {
          name = "certificates"
          secret {
            secret_name = kubernetes_manifest.internal_certificate.manifest.metadata.name
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "garage-data"
      }
      spec {
        storage_class_name = "local-path"
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "${var.required_storage}Gi"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "garage-meta"
      }
      spec {
        storage_class_name = "local-path"
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "${var.required_storage}Gi"
          }
        }
      }
    }
  }
}
