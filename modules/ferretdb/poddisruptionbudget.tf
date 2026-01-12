resource "kubernetes_pod_disruption_budget_v1" "cnpg_pdb" {
  metadata {
    name      = "cnpg-cluster-pdb"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "pdb"
    }
  }

  spec {
    min_available = 1
    selector {
      match_labels = {
        "cnpg.io/cluster" = var.cluster_name
      }
    }
  }

  depends_on = [kubernetes_manifest.cluster]
}

resource "kubernetes_pod_disruption_budget_v1" "ferret_pdb" {
  metadata {
    name      = "ferret-pdb"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "pdb"
    }
  }

  spec {
    min_available = 1
    selector {
      match_labels = {
        app = var.app_name
        component = "pod"
        "part-of" = "ferretdb"
      }
    }
  }

  depends_on = [kubernetes_deployment.ferretdb]
}
