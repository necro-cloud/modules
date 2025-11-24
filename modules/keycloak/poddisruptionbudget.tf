resource "kubernetes_pod_disruption_budget_v1" "keycloak_pdb" {
  metadata {
    name      = "keycloak-cluster-pdb"
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
        app       = var.app_name
        component = "pod"
        "part-of" = "keycloak"
      }
    }
  }

  depends_on = [kubernetes_stateful_set.keycloak_cluster]
}
