locals {
  configurator_options = {
    adminApiUrl         = "https://garage-0.${kubernetes_service.garage-headless.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local:3943"
    k8sClusterName      = var.garage_cluster_name
    k8sClusterNamespace = kubernetes_namespace.namespace.metadata[0].name
    region              = var.garage_region
    desiredReplicas     = var.cluster_nodes
    nodeTags            = var.garage_node_tags
    buckets             = var.required_buckets
    storagePerNodeInGBs = var.required_storage
    accessKeysSecretAnnotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.access_namespaces
    }
    accessKeysSecretLabels = {
      app            = var.app_name
      component      = "secret"
      "generated-by" = "garage-configurator"
    }
    accessKeys = var.required_access_keys
  }
}
