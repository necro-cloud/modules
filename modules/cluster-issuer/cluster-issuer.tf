// Self Signed Issuer for cluster domain services
resource "kubernetes_manifest" "cluster_self_signed_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "${var.cluster_issuer_name}"
      "labels" = {
        "app"       = "base"
        "component" = "clusterissuer"
      }
    }
    "spec" = {
      "selfSigned" = {}
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
}
