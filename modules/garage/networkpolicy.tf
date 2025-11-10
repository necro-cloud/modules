# Fetching Kubernetes Endpoint for API Access
data "kubernetes_endpoints_v1" "kubernetes_api_endpoint" {
  metadata {
    name      = "kubernetes"
    namespace = "default"
  }
}

// Network policy to restrict network access to the Garage Cluster
resource "kubernetes_network_policy" "garage_network_access_policy" {
  metadata {
    name      = "garage-network-access-policy"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "networkpolicy"
    }
  }

  spec {
    pod_selector {
      match_labels = {
        "app"       = var.app_name
        "component" = "pod"
        "part-of"   = "garage"
      }
    }

    policy_types = ["Ingress", "Egress"]

    # -------------- INGRESS RULES -------------- #
    # Rule 1: Allow ingress from other Garage Pods
    ingress {
      from {
        pod_selector {
          match_labels = {
            "app"       = var.app_name
            "component" = "pod"
            "part-of"   = "garage"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 3901
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
            "garage-access" = true
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 3940
      }
    }

    # Rule 3: Allow ingress from NGINX Ingress pods
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
        port     = 3940
      }
    }

    # Rule 4: Allow ingress from Garage Configurator
    ingress {
      from {
        pod_selector {
          match_labels = {
            "app"       = var.app_name
            "component" = "pod"
            "created-by" : "configurator"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 3943
      }
    }

    # -------------- INGRESS RULES -------------- #
    # Rule 1: Allow egress to other Garage pods
    egress {
      to {
        pod_selector {
          match_labels = {
            "app"       = var.app_name
            "component" = "pod"
            "part-of"   = "garage"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 3901
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

    # Rule 3: Allow Egress to Kubernetes API
    egress {
      to {
        ip_block {
          cidr = "${element(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset, 0).address[0].ip}/32"
        }
      }
      ports {
        protocol = element(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset, 0).port[0].protocol
        port     = element(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset, 0).port[0].port
      }
    }
  }
}
