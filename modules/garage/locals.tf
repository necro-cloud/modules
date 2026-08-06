locals {
  configurator_options = {
    adminApiUrl         = "https://garage-0.${kubernetes_service.garage-headless.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local:${local.garage_admin_port}"
    k8sClusterName      = var.garage_cluster_name
    k8sClusterNamespace = kubernetes_namespace.namespace.metadata[0].name
    region              = var.garage_region
    desiredReplicas     = var.cluster_nodes
    nodeTags            = var.garage_node_tags
    buckets             = var.required_buckets
    storagePerNodeInGBs = var.required_storage
    accessKeysSecretAnnotations = {}
    accessKeysSecretLabels = {
      app            = var.app_name
      component      = "secret"
      "generated-by" = "garage-configurator"
    }
    accessKeys = var.required_access_keys
  }
  garage_port = var.enable_internal_tls_certificates ? 3940 : 3900
  garage_admin_port = var.enable_internal_tls_certificates ? 3943 : 3903
}
