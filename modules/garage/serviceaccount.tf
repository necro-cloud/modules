# ---------- SERVICE ACCOUNT TO BE USED BY GARAGE NODES FOR NODE DISCOVERY ---------- #
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

# ---------- SERVICE ACCOUNT TO BE USED BY GARAGE CONFIGURATOR FOR GARAGE SETUP ---------- #

resource "kubernetes_role" "garage_configurator_role" {
  metadata {
    name      = "garage-configurator-role"
    namespace = kubernetes_namespace.namespace[0].name
    labels = {
      app       = var.app_name
      component = "role"
    }
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["statefulsets"]
    resource_names = [kubernetes_stateful_set.statefulset.metadata[0].name]
    verbs          = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "create"]
  }
}

resource "kubernetes_service_account" "garage_configurator_service_account" {
  metadata {
    name      = "garage-configurator-service-account"
    namespace = kubernetes_namespace.namespace[0].name
    labels = {
      app       = var.app_name
      component = "serviceaccount"
    }
  }
}

resource "kubernetes_role_binding" "garage_configurator_role_binding" {
  metadata {
    name      = "garage-configurator-role-binding"
    namespace = kubernetes_namespace.namespace[0].name
    labels = {
      app       = var.app_name
      component = "rolebinding"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.garage_configurator_service_account.metadata[0].name
    namespace = kubernetes_service_account.garage_configurator_service_account.metadata[0].namespace
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.garage_configurator_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}
