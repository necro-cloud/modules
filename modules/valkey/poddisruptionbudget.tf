resource "kubernetes_pod_disruption_budget_v1" "valkey_pdb" {
  metadata {
    name      = "valkey-cluster-pdb"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "pdb"
    }
  }

  spec {
    min_available = 2
    selector {
      match_labels = {
        app       = var.app_name
        "part-of" = "valkey-cluster"
      }
    }
  }

  depends_on = [kubernetes_stateful_set.valkey_cluster]
}
