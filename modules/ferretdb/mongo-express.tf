resource "kubernetes_deployment" "mongo_express" {
  metadata {
    name = "mongo-express"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        "ferret-mongo-access" = true
        app       = var.app_name
        component = "pod"
        used-for  = "mongo-express"
      }
    }

    template {
      metadata {
        labels = {
          "ferret-mongo-access" = true
          app       = var.app_name
          component = "pod"
          used-for  = "mongo-express"
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
          name = "mongo-express"
          image = "${var.mongo_express_repository}/${var.mongo_express_image}:${var.mongo_express_tag}"

          // FerretDB Connection Settings
          env {
            name = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ferret_database_credentials.metadata[0].name
                key  = "username"
              }
            }
          }
          
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ferret_database_credentials.metadata[0].name
                key  = "password"
              }
            }
          }
          
          env {
            name = "ME_CONFIG_MONGODB_URL"
            value = "mongodb://$(DB_USERNAME):$(DB_PASSWORD)@${kubernetes_service.ferret_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local:27017/ferret?authMechanism=SCRAM-SHA-256"
          }

          env {
            name = "ME_CONFIG_MONGODB_ENABLE_ADMIN"
            value = "true"
          }

          // UI Authentication for Mongo Express
          env {
            name = "ME_CONFIG_BASICAUTH_ENABLED"
            value = "true"
          }

          env {
            name = "ME_CONFIG_BASICAUTH_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ui_credentials.metadata[0].name
                key = "username"
              }
            }
          }
          
          env {
            name = "ME_CONFIG_BASICAUTH_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ui_credentials.metadata[0].name
                key = "password"
              }
            }
          }

          // SSL Configuration for Mongo Express
          env {
            name = "ME_CONFIG_SITE_SSL_ENABLED"
            value = "true"
          }

          env {
            name = "ME_CONFIG_SITE_SSL_CRT_PATH"
            value = "/etc/mongoexpress/certs/tls.crt"
          }
          
          env {
            name = "ME_CONFIG_SITE_SSL_KEY_PATH"
            value = "/etc/mongoexpress/certs/tls.key"
          }

          port {
            container_port = 8081
            name = "mongoexpress"
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
          
          liveness_probe {
            http_get {
              path = "/status"
              port = 8081
              scheme = "HTTPS"
            }
            initial_delay_seconds = 10
            period_seconds = 10
            success_threshold = 1
            failure_threshold = 5
          }
          
          readiness_probe {
            http_get {
              path = "/status"
              port = 8081
              scheme = "HTTPS"
            }
            initial_delay_seconds = 10
            period_seconds = 10
            success_threshold = 1
            failure_threshold = 5
          }

          volume_mount {
            name = "tls-certs"
            mount_path = "/etc/mongoexpress/certs"
            read_only = true
          }
        }

        volume {
          name = "tls-certs"
          secret {
            secret_name = kubernetes_manifest.mongo_express_internal_certificate.manifest.spec.secretName
          }
        }
      }
    }
  }

  depends_on = [ kubernetes_deployment.ferretdb ]
}
