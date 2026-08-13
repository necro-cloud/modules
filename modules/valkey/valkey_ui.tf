# UI Component for Valkey
resource "kubernetes_deployment" "valkey_ui" {
  count = var.enable_ui ? 1 : 0
  metadata {
    name      = "valkey-ui"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "deployment"
    }
  }

  spec {
    replicas = 1

    // Selectors for the pods
    // Network policy will also be applied here
    selector {
      match_labels = {
        app                = var.app_name
        component          = "pod"
        "part-of"          = "valkey-ui"
        "valkey-ui-access" = true
      }
    }

    template {
      metadata {
        labels = {
          app                = var.app_name
          component          = "pod"
          "part-of"          = "valkey-ui"
          "valkey-ui-access" = true
        }
      }

      spec {

        // Node Affinity rule to run only on worker nodes
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "worker"
                  operator = "Exists"
                }
              }
            }
          }
        }

        // Topology Spread to ensure pods are running on seperate nodes
        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "DoNotSchedule"
          label_selector {
            match_labels = {
              app                = var.app_name
              component          = "pod"
              "part-of"          = "valkey-ui"
              "valkey-ui-access" = true
            }
          }
        }

        container {
          name  = "valkey-ui"
          image = "${var.ui_repository}/${var.ui_image}:${var.ui_tag}"

          # HTTP Mapping for the UI service
          port {
            container_port = 8081
            name           = "http"
          }

          # Password to authenticate against Valkey
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_manifest.valkey_credentials_sync.object.spec.target.name
                key  = "VALKEY_PASSWORD"
              }
            }
          }

          # Full Configuration for the UI Solution
          env_from {
            secret_ref {
              name = kubernetes_secret.redis_commander_configuration[0].metadata[0].name
            }
          }

          # Credentials configuration for Redis Commander          
          env_from {
            secret_ref {
              name = kubernetes_manifest.ui_credentials_sync[0].object.spec.target.name
            }
          }

          # Mounting the SSL certs for communicating with Valkey in TLS
          dynamic "volume_mount" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name       = "certificates"
              mount_path = "/mnt/certs"
            }
          }

          # Health checks to turn green
          # when the UI service is up
          liveness_probe {
            http_get {
              path = "/favicon.png"
              port = 8081
            }
            period_seconds    = 10
            success_threshold = 1
            failure_threshold = 5
          }

          readiness_probe {
            http_get {
              path = "/favicon.png"
              port = 8081
            }
            period_seconds    = 10
            success_threshold = 1
            failure_threshold = 5
          }

          # Use non root credentials to run the containers
          security_context {
            run_as_group    = 10000
            run_as_non_root = true
            run_as_user     = 10000
          }

        }

        dynamic "container" {
          for_each = var.enable_internal_tls_certificates ? [true] : []
          content {
            name  = "proxy"
            image = "${var.proxy_repository}/${var.proxy_image}:${var.proxy_tag}"

            # HTTPS Mapping for the UI service
            port {
              container_port = 8443
              name           = "https"
            }

            # Mounting the SSL certs for HTTPS duties
            volume_mount {
              name       = "certificates"
              mount_path = "/mnt/ssl"
            }

            # NGINX Configuration for HTTPS duties
            volume_mount {
              name       = "nginx-config"
              mount_path = "/etc/nginx"
            }

            # Liveness and readiness probes to check if the container is up
            liveness_probe {
              exec {
                command = ["curl", "--cacert", "/mnt/ssl/ca.crt", "https://localhost:8443/favicon.png"]
              }
              period_seconds = 30
            }

            readiness_probe {
              exec {
                command = ["curl", "--cacert", "/mnt/ssl/ca.crt", "https://localhost:8443/favicon.png"]
              }
              period_seconds = 30
            }

            # Use non root credentials to run the containers
            security_context {
              run_as_group    = 1000
              run_as_non_root = true
              run_as_user     = 1000
            }
          }
        }


        # Mount the certificates for Valkey to communicate TLS with
        dynamic "volume" {
          for_each = var.enable_internal_tls_certificates ? [true] : []
          content {
            name = "ca-certs"
            secret {
              secret_name = kubernetes_manifest.internal_certificate[0].object.spec.secretName
            }
          }
        }

        # Mount the certificates required to perform TLS connections
        dynamic "volume" {
          for_each = var.enable_internal_tls_certificates ? [true] : []
          content {
            name = "certificates"
            secret {
              secret_name = kubernetes_manifest.ui_internal_certificate[0].object.spec.secretName
            }
          }
        }

        # Mount the confiuration for NGINX to perform internal TLS duties
        dynamic "volume" {
          for_each = var.enable_internal_tls_certificates ? [true] : []
          content {
            name = "nginx-config"
            config_map {
              name = kubernetes_config_map.ui_nginx_conf[0].metadata[0].name
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_manifest.internal_certificate
  ]
}
