// Network policy to restrict network access to the Valkey Cluster
resource "kubernetes_manifest" "valkey_network_policy" {
  manifest = {
    "apiVersion" = "projectcalico.org/v3"
    "kind"       = "NetworkPolicy"
    "metadata" = {
      "name"      = "valkey-network-access"
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "networkpolicy"
      }
    }

    "spec" = {
      "selector" = "app == '${var.app_name}' && part-of == 'valkey-cluster'"
      "types"    = ["Ingress", "Egress"]

      # -------------- INGRESS RULES -------------- #
      "ingress" = [
        # Rule 1: Allow Cluster Intercommunication Ingress
        {
          "action"   = "Allow"
          "protocol" = "TCP"
          "source" = {
            "selector" = "app == '${var.app_name}' && part-of == 'valkey-cluster'"
          }
          "destination" = {
            "ports" = [6379]
          }
        },

        # Rule 2: Allow Network Ingress from allowed namespaces
        {
          "action"   = "Allow"
          "protocol" = "TCP"
          "source" = {
            "selector"          = "valkey-access == 'true'"
            "namespaceSelector" = "kubernetes.io/metadata.name in {${join(", ", formatlist("'%s'", var.replication_namespaces))}}"
          }
          "destination" = {
            "ports" = [6379]
          }
        }
      ]

      # -------------- EGRESS RULES -------------- #
      "egress" = [
        # Rule 1: Allow Valkey pods to send traffic to each other.
        {
          "action"   = "Allow"
          "protocol" = "TCP"
          "destination" = {
            "selector" = "app == '${var.app_name}' && part-of == 'valkey-cluster'"
            "ports"    = [6379]
          }
        },

        # Rule 2: Allow DNS resolution to kube-dns.
        {
          "action"   = "Allow"
          "protocol" = "UDP"
          "destination" = {
            "selector"          = "k8s-app == 'kube-dns'"
            "namespaceSelector" = "kubernetes.io/metadata.name == 'kube-system'"
            "ports"             = [53]
          }
        },
      ]
    }
  }
}
