resource "kubernetes_deployment" "ferretdb" {
  metadata {
    name = "ferret"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = var.app_name
      component = "deployment"
    }
  }

  spec {
    replicas = var.cluster_size
    selector {
      match_labels = {
        app = var.app_name
        component = "pod"
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
          component = "pod"
          "ferret-access" = "true"
          "part-of" = "ferretdb"
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
              "part-of" = "ferretdb"
            }
          }
        }

        container {
          name = "ferret"
          image = "ghcr.io/ferretdb/ferretdb:2.7.0"

          port {
            container_port = 27017
            name = "mongo"
          }
          
          port {
            container_port = 8088
            name = "debug"
          }

          resources {
            requests = {
              cpu = "250m"
              memory = "256Mi"
            }
            limits = {
              cpu = "500m"
              memory = "500Mi"
            }
          }

          // PostgreSQL Certificates
          volume_mount {
            name = "postgres-ca"
            mount_path = "/etc/certs"
            read_only = true
          }

          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ferret_database_credentials.metadata[0].name
                key = "username"
              }
            }
          }
          env {
            name = "DB_PASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ferret_database_credentials.metadata[0].name
                key = "password"
              }
            }
          }
          env {
            name = "DB_HOST"
            value = "ferret-postgresql-cluster-rw"
          }
          env {
            name = "FERRETDB_POSTGRESQL_URL"
            value = "postgres://$(DB_USER):$(DB_PASS)@$(DB_HOST):5432/ferret?sslmode=verify-ca&sslrootcert=/etc/certs/ca.crt"
          }

          readiness_probe {
            tcp_socket {
              port = 27017
            }
            initial_delay_seconds = 10
            period_seconds = 10
            success_threshold = 3
            failure_threshold = 5
          }

          liveness_probe {
            http_get {
              path = "/debug/livez"
              port = 8088
            }
            initial_delay_seconds = 10
            period_seconds = 10
            success_threshold = 1
            failure_threshold = 5
          }
        }

        volume {
          name = "postgres-ca"
          secret {
            secret_name = kubernetes_manifest.server_certificate_authority.manifest.spec.secretName
            items {
              key = "ca.crt"
              path = "ca.crt"
            }
          }
        }
      }
    }
  }

  depends_on = [ kubernetes_manifest.cluster, kubernetes_manifest.ferret_database, kubernetes_job.ferret_permissions ]
}
