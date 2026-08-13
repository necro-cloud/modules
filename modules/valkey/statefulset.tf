// StatefulSet Definition for Valkey
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
    replicas     = local.size_lookup[var.cluster_size]

    selector {
      match_labels = {
        app       = var.app_name
        "part-of" = "valkey-cluster"
      }
    }

    // Pod Template Definition
    template {
      metadata {
        labels = {
          app       = var.app_name
          "part-of" = "valkey-cluster"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "9121"
          "prometheus.io/scheme" = "http"
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
              "part-of" = "valkey-cluster"
            }
          }
        }

        // Container Definition for the Pod
        container {
          name  = "valkey"
          image = "${var.repository}/${var.image}:${var.tag}"

          // Start command for the container
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

          // Valkey Password Environment Variable
          env_from {
            secret_ref {
              name = kubernetes_manifest.valkey_credentials_sync.object.spec.target.name
            }
          }

          // Ports Definition
          port {
            container_port = 6379
            name           = "valkey"
          }

          // Resources Definition
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

          // Probes for checking on pods
          readiness_probe {
            exec {
              command = var.enable_internal_tls_certificates ? ["sh", "-c", "valkey-cli --tls --cacert /etc/valkey/tls/ca.crt --cert /etc/valkey/tls/tls.crt --key /etc/valkey/tls/tls.key --pass $VALKEY_PASSWORD PING | grep PONG"] : ["sh", "-c", "valkey-cli --pass $VALKEY_PASSWORD PING | grep PONG"]
            }

            initial_delay_seconds = 20
            period_seconds        = 10
            timeout_seconds       = 10
            failure_threshold     = 3
          }

          liveness_probe {
            exec {
              command = var.enable_internal_tls_certificates ? ["sh", "-c", "valkey-cli --tls --cacert /etc/valkey/tls/ca.crt --cert /etc/valkey/tls/tls.crt --key /etc/valkey/tls/tls.key --pass $VALKEY_PASSWORD PING | grep PONG"] : ["sh", "-c", "valkey-cli --pass $VALKEY_PASSWORD PING | grep PONG"]
            }

            initial_delay_seconds = 20
            period_seconds        = 10
            timeout_seconds       = 10
            failure_threshold     = 3
          }

          // Volume Mounts for Configuration and Data
          volume_mount {
            name       = "template-configuration"
            mount_path = "/etc/valkey/conf_template"
          }

          volume_mount {
            name       = "configuration"
            mount_path = "/etc/valkey/conf"
          }

          dynamic "volume_mount" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name       = "certificates"
              mount_path = "/etc/valkey/tls"
            }
          }

          volume_mount {
            name       = "valkey-data"
            mount_path = "/data"
          }
        }

        // Valkey Exporter for exposing Prometheus Metrics
        container {
          name = "metrics"
          image = "${var.metrics_repository}/${var.metrics_image}:${var.metrics_tag}"

          port {
            name           = "metrics"
            container_port = 9121
          }

          // Valkey Connection String
          env {
            name  = "REDIS_ADDR"
            value = "rediss://localhost:6379" 
          }

          // Password Authentication for the cluster
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_manifest.valkey_credentials_sync.object.spec.target.name
                key  = "VALKEY_PASSWORD"
              }
            }
          }

          // Using certificates for proper TLS connection to the cluster
          dynamic "env" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name  = "REDIS_EXPORTER_TLS_CA_CERT_FILE"
              value = "/etc/valkey/tls/ca.crt"
            }
          }
          dynamic "env" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name  = "REDIS_EXPORTER_TLS_CLIENT_CERT_FILE"
              value = "/etc/valkey/tls/tls.crt"
            }
          }
          dynamic "env" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name  = "REDIS_EXPORTER_TLS_CLIENT_KEY_FILE"
              value = "/etc/valkey/tls/tls.key"
            }
          }

          // Optionally skip verifying the hostname on the cert since we are using localhost
          dynamic "env" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name  = "REDIS_EXPORTER_SKIP_TLS_VERIFICATION"
              value = "true"
            }
          }

          // Mounting the exact same certificate volume used by the Valkey container
          dynamic "volume_mount" {
            for_each = var.enable_internal_tls_certificates ? [true] : []
            content {
              name       = "certificates"
              mount_path = "/etc/valkey/tls"
              read_only  = true
            }
          }
          
          // Tiny resource footprint for metrics
          resources {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }                    
        }

        volume {
          name = "template-configuration"
          config_map {
            name = var.enable_internal_tls_certificates ? kubernetes_config_map.valkey_conf[0].metadata[0].name : kubernetes_config_map.valkey_conf_no_tls[0].metadata[0].name
          }
        }

        volume {
          name = "configuration"
          empty_dir {}
        }

        dynamic "volume" {
          for_each = var.enable_internal_tls_certificates ? [true] : []
          content {
            name = "certificates"
            secret {
              secret_name = kubernetes_manifest.internal_certificate[0].manifest.spec.secretName
            }
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
