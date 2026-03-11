// Network policy to restrict network access to the OpenBao Cluster
resource "kubernetes_network_policy" "openbao_network_access_policy" {
  metadata {
    name      = "openbao-network-access-policy"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "networkpolicy"
    }
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "openbao"
        "component"              = "server"
      }
    }

    policy_types = ["Ingress", "Egress"]

    # -------------- INGRESS RULES -------------- #
    # Rule 1: Allow Raft replication and internal API communication between OpenBao Pods
    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "openbao"
            "component"              = "server"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 8200
      }
      ports {
        protocol = "TCP"
        port     = 8201
      }
    }

    # Rule 2: Allow ingress from trusted namespaces
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
            "openbao-access" = "true"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 8200
      }
    }

    # Rule 3: Allow ingress from configurator job
    ingress {
      from {
        namespace_selector {
          match_expressions {
            key      = "kubernetes.io/metadata.name"
            operator = "In"
            values   = [kubernetes_namespace.namespace.metadata[0].name]
          }
        }
        pod_selector {
          match_labels = {
            "created-by" = "configurator"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 8200
      }
    }    

    # Rule 4: Allow NGINX Ingress Controller to reach the active leader
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "ingress-nginx"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 8200
      }
    }

    # Rule 5: Allow OpenTelemetry Collector to scrape metrics from the API port
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
        port     = 8200
      }
    }

    # -------------- EGRESS RULES -------------- #
    # Rule 1: Allow egress to other OpenBao pods for Raft consensus
    egress {
      to {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "openbao"
            "component"              = "server"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 8200
      }
      ports {
        protocol = "TCP"
        port     = 8201
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
      ports {
        protocol = "TCP"
        port     = 53
      }
    }

    # Rule 3: Allow egress to the Kubernetes API for Discovery and Auth
    egress {
      to {
        ip_block {
          cidr = "${var.kubernetes_api_ip}/32"
        }
      }
      ports {
        protocol = var.kubernetes_api_protocol
        port     = var.kubernetes_api_port
      }
    }
  }
}
