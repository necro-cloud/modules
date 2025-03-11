// Keycloak Stateful Set Cluster
resource "kubernetes_stateful_set" "keycloak_cluster" {
  metadata {
    name      = "keycloak-cluster"
    namespace = var.namespace
    labels = {
      app       = "keycloak"
      component = "statefulset"
    }
  }
  spec {
    replicas     = 1
    service_name = ""

    // Stateful Set Pod Selector
    selector {
      match_labels = {
        app       = "keycloak"
        component = "pod"
      }
    }

    // Pod Template
    template {

      // Pod Metadata
      metadata {
        labels = {
          app       = "keycloak"
          component = "pod"
        }
      }

      // Pod Spec
      spec {

        // Container Details
        container {
          name  = "keycloak"
          image = "quay.io/keycloak/keycloak:26.0.7"
          args  = ["-Djgroups.dns.query=keycloak-discovery.keycloak", "--verbose", "start", "--import-realm"]

          // Environment Variables
          env {
            name  = "KC_HOSTNAME"
            value = "${var.host_name}.${var.domain}"
          }

          dynamic "env" {
            for_each = var.keycloak_environment_variables
            content {
              name  = env.value["name"]
              value = env.value["value"]
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.keycloak_credentials.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.realm_secrets.metadata[0].name
            }
          }

          env {
            name  = "KC_DB"
            value = "postgres"
          }

          env {
            name = "KC_DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "KC_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "password"
              }
            }
          }

          // Port Mappings
          dynamic "port" {
            for_each = var.keycloak_ports
            content {
              name           = port.value["name"]
              container_port = port.value["containerPort"]
              protocol       = port.value["protocol"]
            }
          }

          // Startup, Liveness and Readiness Probes
          startup_probe {
            failure_threshold = 3
            http_get {
              path   = "/health/started"
              port   = "management"
              scheme = "HTTPS"
            }
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 10
            initial_delay_seconds = 60
          }

          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/health/ready"
              port   = "management"
              scheme = "HTTPS"
            }
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 10
            initial_delay_seconds = 60
          }

          liveness_probe {
            failure_threshold = 3
            http_get {
              path   = "/health/live"
              port   = "management"
              scheme = "HTTPS"
            }
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 10
            initial_delay_seconds = 60
          }

          // Resource limitations
          resources {
            requests = {
              "cpu"    = "500m"
              "memory" = "1Gi"
            }

            limits = {
              "cpu"    = "500m"
              "memory" = "1Gi"
            }
          }

          // Volume mounts
          volume_mount {
            name       = kubernetes_secret.database_server_certificate_authority.metadata[0].name
            mount_path = "/mnt/certs/database/certificate-authority"
          }

          volume_mount {
            name       = kubernetes_secret.database_client_certificate.metadata[0].name
            mount_path = "/mnt/certs/database/certificate"
          }

          volume_mount {
            name       = kubernetes_manifest.internal_certificate.manifest.spec.secretName
            mount_path = "/mnt/certs/tls"
          }

          volume_mount {
            name       = kubernetes_config_map.realm_configuration.metadata[0].name
            mount_path = "/opt/keycloak/data/import"
          }
        }

        // Volumes
        volume {
          name = kubernetes_secret.database_server_certificate_authority.metadata[0].name
          secret {
            secret_name = kubernetes_secret.database_server_certificate_authority.metadata[0].name
          }
        }

        volume {
          name = kubernetes_secret.database_client_certificate.metadata[0].name
          secret {
            secret_name = kubernetes_secret.database_client_certificate.metadata[0].name
          }
        }

        volume {
          name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
          secret {
            secret_name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
          }
        }

        volume {
          name = kubernetes_config_map.realm_configuration.metadata[0].name
          config_map {
            name = kubernetes_config_map.realm_configuration.metadata[0].name
          }
        }

        security_context {
          fs_group    = 1000
          run_as_user = 1000
        }

      }
    }

    update_strategy {
      rolling_update {
        partition = 0
      }
      type = "RollingUpdate"
    }
  }

  depends_on = [kubernetes_service.keycloak_service, kubernetes_service.keycloak_discovery]
}
