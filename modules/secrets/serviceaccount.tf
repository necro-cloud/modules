// Service account to be used by the Configurator Job
resource "kubernetes_service_account" "configurator" {
  metadata {
    name      = "openbao-configurator"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "serviceaccount"
    }
  }
}

// Allow the Configurator Job to create Kubernetes Secrets
resource "kubernetes_role" "configurator" {
  metadata {
    name      = "openbao-configurator-role"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "role"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "get"]
  }
}

// Binding the role to the Service Account
resource "kubernetes_role_binding" "configurator" {
  metadata {
    name      = "openbao-configurator-binding"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "rolebinding"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.configurator.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.configurator.metadata[0].name
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
}
