// Network policy to restrict network access to the Keycloak
resource "kubernetes_network_policy" "keycloak_network_access_policy" {
  metadata {
    name      = "keycloak-network-access-policy"
    namespace = var.namespace
  }
  spec {
    policy_types = ["Ingress", "Egress"]

    pod_selector {
      match_labels = {
        app       = "keycloak"
        component = "pod"
      }
    }

    # -------------- INGRESS RULES -------------- #
    # Rule 1: Allow ingress from NGINX Ingress
    ingress {
      from {
        namespace_selector {
          match_expressions {
            key      = "kubernetes.io/metadata.name"
            operator = "In"
            values   = ["ingress-nginx"]
          }
        }
        pod_selector {
          match_labels = {
            "app.kubernetes.io/component" = "controller"
            "app.kubernetes.io/name"      = "ingress-nginx"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 8443
      }
    }

    # Rule 2: Allow ingress from other Keycloak Pods
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = kubernetes_namespace.namespace.metadata[0].name
          }
        }
        pod_selector {
          match_labels = {
            app       = "keycloak"
            component = "pod"
            "part-of" = "keycloak"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 7800
      }
      ports {
        protocol = "TCP"
        port     = 57800
      }
    }

    # -------------- EGRESS RULES -------------- #
    # Rule 1: Allow egress to KubeDNS for DNS resolutions
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

    # Rule 2: Allow egress to PostgreSQL Database
    egress {
      to {
        pod_selector {
          match_labels = {
            "cnpg.io/cluster" = var.cluster_name
          }
        }
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.postgres_namespace
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 5432
      }
    }

    # Rule 3: Allow egress to other Keycloak Pods
    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = kubernetes_namespace.namespace.metadata[0].name
          }
        }
        pod_selector {
          match_labels = {
            app       = "keycloak"
            component = "pod"
            "part-of" = "keycloak"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 7800
      }
      ports {
        protocol = "TCP"
        port     = 57800
      }
    }
  }
}
