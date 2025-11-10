resource "kubernetes_pod_disruption_budget_v1" "garage_pdb" {
  metadata {
    name      = "garage-cluster-pdb"
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
        component = "pod"
        "part-of" = "garage"
      }
    }
  }

  depends_on = [kubernetes_stateful_set.statefulset]
}
