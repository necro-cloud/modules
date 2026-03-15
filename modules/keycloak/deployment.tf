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
    replicas     = var.replicas
    service_name = ""

    // Stateful Set Pod Selector
    selector {
      match_labels = {
        app         = "keycloak"
        component   = "pod"
        "part-of"   = "keycloak"
        "pg-access" = true
      }
    }

    // Pod Template
    template {

      // Pod Metadata
      metadata {
        labels = {
          app         = "keycloak"
          component   = "pod"
          "part-of"   = "keycloak"
          "pg-access" = true
        }

        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/path"   = "/metrics"
          "prometheus.io/port"   = "9000" 
          "prometheus.io/scheme" = "https"
        }
      }

      // Pod Spec
      spec {

        init_container {
          name = "certificate-converter"
          image = "alpine:3.23.3"
          command = ["/bin/sh", "-c"]

          args = [
            "apk add --no-cache openssl && openssl pkcs8 -topk8 -inform PEM -outform DER -in /mnt/certs/database/certificate/tls.key -out /mnt/der/key.der -nocrypt && chown 1000:0 /mnt/der/key.der && chmod 600 /mnt/der/key.der"
          ]

          volume_mount {
            name       = "database-client-certificate"
            mount_path = "/mnt/certs/database/certificate"
            read_only  = true
          }

          volume_mount {
            name       = "database-der-key"
            mount_path = "/mnt/der"
          }          
        }

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
              "part-of" = "keycloak"
            }
          }
        }

        // Container Details
        container {
          name  = "keycloak"
          image = "${var.repository}/${var.image}:${var.tag}"
          args  = ["--verbose", "start", "--import-realm"]

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
            name = "KC_METRICS_ENABLED"
            value = "true"
          }

          env {
            name = "KC_EVENT_METRICS_USER_ENABLED"
            value = "true"
          }

          env {
            name = "KC_EVENT_METRICS_USER_TAGS"
            value = "realm,idp,clientId"
          }

          env {
            name = "KC_DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_manifest.database_credentials_sync.object.spec.target.name
                key  = "username"
              }
            }
          }

          env {
            name = "KC_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_manifest.database_credentials_sync.object.spec.target.name
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
            name       = "database-certificate-authority"
            mount_path = "/mnt/certs/database/certificate-authority"
          }

          volume_mount {
            name       = "database-der-key"
            mount_path = "/mnt/der"
            read_only  = true
          }          

          volume_mount {
            name       = "database-client-certificate"
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
          name = "database-certificate-authority"
          secret {
            secret_name = kubernetes_manifest.database_server_certificate_authority_sync.object.spec.target.name
          }
        }

        volume {
          name = "database-der-key"
          empty_dir {}
        }        

        volume {
          name = "database-client-certificate"
          secret {
            secret_name = kubernetes_manifest.database_client_certificate_sync.object.spec.target.name
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

  depends_on = [
    kubernetes_service.keycloak_service,
    kubernetes_service.keycloak_discovery,
    kubernetes_manifest.database_credentials_sync,
    kubernetes_manifest.database_client_certificate_sync,
    kubernetes_manifest.database_server_certificate_authority_sync
  ]
}
