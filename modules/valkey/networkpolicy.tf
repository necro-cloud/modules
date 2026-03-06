// Network policy to restrict network access to the Valkey Cluster
resource "kubernetes_network_policy" "valkey_network_access_policy" {
  metadata {
    name      = "valkey-network-access-policy"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "networkpolicy"
    }
  }

  spec {
    pod_selector {
      match_labels = {
        "app"     = var.app_name
        "part-of" = "valkey-cluster"
      }
    }

    policy_types = ["Ingress", "Egress"]

    # -------------- INGRESS RULES -------------- #
    # Rule 1: Allow ingress from other Valkey Pods
    ingress {
      from {
        pod_selector {
          match_labels = {
            "app"     = var.app_name
            "part-of" = "valkey-cluster"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 6379
      }
    }

    # Rule 2: Allow ingress from trusted pods in trusted namespaces
    ingress {
      from {
        namespace_selector {
          match_expressions {
            key      = "kubernetes.io/metadata.name"
            operator = "In"
            values   = split(",", var.access_namespaces)
          }
        }
        pod_selector {
          match_labels = {
            "valkey-access" = true
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 6379
      }
    }

    # Rule 3: Allow OpenTelemetry Collector to scrape Garage metrics
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.observability_namespace
          }
        }

        pod_selector {
          match_labels = {
            "app.kubernetes.io/instance" = "otel-collector" 
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 9121
      }
    }

    # -------------- INGRESS RULES -------------- #
    # Rule 1: Allow egress to other Valkey pods
    egress {
      to {
        pod_selector {
          match_labels = {
            "app"     = var.app_name
            "part-of" = "valkey-cluster"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 6379
      }
    }

    # Rule 2: Allow DNS resolution to KubeDNS
    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
        pod_selector {
          match_labels = {
            "k8s-app" = "kube-dns"
          }
        }
      }
      ports {
        protocol = "UDP"
        port     = 53
      }
    }
  }
}
