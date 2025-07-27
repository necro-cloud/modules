resource "kubernetes_cluster_role" "garage_crds" {
  metadata {
    name = "garage-crds-role"
    labels = {
      app       = var.app_name
      component = "clusterrole"
    }
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["get", "list", "watch", "create", "patch"]
  }

  rule {
    api_groups = ["deuxfleurs.fr"]
    resources  = ["garagenodes"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_service_account" "garage_service_account" {
  metadata {
    name      = "garage-service-account"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "serviceaccount"
    }
  }
}

resource "kubernetes_cluster_role_binding" "garage_crds_rolebindings" {
  metadata {
    name = "garage-crds-rolebindings"
    labels = {
      app       = var.app_name
      component = "rolebinding"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.garage_service_account.metadata[0].name
    namespace = kubernetes_service_account.garage_service_account.metadata[0].namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.garage_crds.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}
