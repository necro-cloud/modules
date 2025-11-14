// Fetching Kubernetes Endpoint for API Access
data "kubernetes_endpoints_v1" "kubernetes_api_endpoint" {
  metadata {
    name      = "kubernetes"
    namespace = "default"
  }
}

resource "kubernetes_network_policy" "cnpg_network_policy" {
  metadata {
    name      = "cnpg-network-policy"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "networkpolicy"
    }
  }

  spec {
    pod_selector {
      match_labels = {
        "cnpg.io/cluster" = var.cluster_name
      }
    }

    policy_types = ["Ingress", "Egress"]

    # -------------- INGRESS RULES -------------- #
    # Rule 1: Allow ingress from other CNPG Operator
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "cnpg-system"
          }
        }

        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "cloudnative-pg"
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 8000
      }
      ports {
        protocol = "TCP"
        port     = 5432
      }
    }

    # Rule 2: Allow ingress from other CNPG pods
    ingress {
      from {
        pod_selector {
          match_labels = {
            "cnpg.io/cluster" = var.cluster_name
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 5432
      }
      ports {
        protocol = "TCP"
        port     = 8000
      }
    }

    # Rule 3: Allow ingress from allowed pods in trusted namespaces
    ingress {
      from {
        namespace_selector {
          match_expressions {
            key      = "kubernetes.io/metadata.name"
            operator = "In"
            values   = concat(local.access_namespaces, ["keycloak", kubernetes_namespace.namespace.metadata[0].name])
          }
        }

        pod_selector {
          match_labels = {
            "pg-access" = true
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 5432
      }
    }

    # -------------- EGRESS RULES -------------- #
    # Rule 1: Allow egress to other CNPG pods
    egress {
      to {
        pod_selector {
          match_labels = {
            "cnpg.io/cluster" = var.cluster_name
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 5433
      }
      ports {
        protocol = "TCP"
        port     = 5432
      }
      ports {
        protocol = "TCP"
        port     = 8000
      }
    }

    # Rule 2: Allow egress to Garage S3 Cluster for PITR
    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.garage_namespace
          }
        }
      }

      ports {
        protocol = "TCP"
        port     = 3940
      }
    }

    # Rule 3: Allow DNS resolution to KubeDNS
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


    # Rule 4: Allow Egress to Kubernetes API
    egress {
      to {
        ip_block {
          cidr = "${one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))}/32"
        }
      }
      ports {
        protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
        port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))
      }
    }
  }
}
