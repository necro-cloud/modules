# UI Component for the Garage Storage Solution
resource "kubernetes_deployment" "garage_ui" {
  count = var.enable_ui ? 1 : 0
  metadata {
    name      = "garage-ui"
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
        app       = var.app_name
        component = "pod"
        "part-of" = "garage-ui"
        "garage-ui-access" = true
      }
    }

    template {
      metadata {
        labels = {
          app       = var.app_name
          component = "pod"
          "part-of" = "garage-ui"
          "garage-ui-access" = true
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
              app       = var.app_name
              component = "pod"
              "part-of" = "garage-ui"
              "garage-ui-access" = true
            }
          }
        }
        
        container {
          name  = "garage-ui"
          image = "${var.ui_repository}/${var.ui_image}:${var.ui_tag}"
          
          # Environment Variables
          env {
            name  = "GARAGE_UI_GARAGE_ADMIN_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_manifest.admin_password_sync.object.spec.target.name
                key = "GARAGE_ADMIN_TOKEN"
              }
            }
          }

          # Set SSL_CERT_DIR so the Go application looks in /certs for CA bundle
          dynamic "env" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name  = "SSL_CERT_DIR"
              value = "/certs"
            }
          }

          # Admin credentials for the UI solution
          env_from {
            secret_ref {
              name = kubernetes_manifest.ui_admin_password_sync.object.spec.target.name
            }
          }

          # UI Configuratio file mounting
          volume_mount {
            name       = "config"
            mount_path = "/app/config.yaml"
            sub_path = "config.yaml"
          }

          # Mount the CA Cert to a directory that Go/OpenSSL will trust
          dynamic "volume_mount" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name       = "ca-certs"
              mount_path = "/certs"
            }
          }

          # HTTP Mapping for the UI service
          port {
            container_port = 8080
            name           = "http"
          }

          # Health checks to turn green
          # when the UI service is up
          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            period_seconds = 10
            success_threshold = 1
            failure_threshold = 5
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            period_seconds = 10
            success_threshold = 1
            failure_threshold = 5
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
              mount_path = "/mnt/crt"
            }

            # NGINX Configuration for HTTPS duties
            volume_mount {
              name       = "nginx-config"
              mount_path = "/etc/nginx"
            }

            # Liveness and readiness probes to check if the container is up
            liveness_probe {
              exec {
                command = ["curl", "--cacert", "/mnt/crt/ca.crt", "https://localhost:8443/health"]
              }
              period_seconds        = 30
            }

            readiness_probe {
              exec {
                command = ["curl", "--cacert", "/mnt/crt/ca.crt", "https://localhost:8443/health"]
              }
              period_seconds        = 30
            }
          }
        }
        
        # Use non root credentials to run the containers
        security_context {
          fs_group        = 1000
          run_as_group    = 1000
          run_as_non_root = true
          run_as_user     = 1000
        }
        
        # Mount the CA certificate from the Garage cluster's internal secret to trust HTTPS
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

        # Mount the Garage UI Configuration from the ConfigMap created for it
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.garage_ui_config[0].metadata[0].name
          }
        }

        # Mount the confiuration for NGINX to perform internal TLS duties
        dynamic "volume" {
          for_each = var.enable_internal_tls_certificates ? [true] : []
          content {
            name = "nginx-config"
            config_map {
              name = kubernetes_config_map.ui_nginx_conf.metadata[0].name
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.garage-headless, 
    kubernetes_config_map.garage_ui_config,
  ]
}
