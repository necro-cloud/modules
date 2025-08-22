resource "kubernetes_config_map" "pgadmin_servers_configuration" {
  metadata {
    name      = "${var.cluster_name}-servers-configuration"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }

  data = {
    "servers.json" = jsonencode(local.pgadmin_servers)
  }
}
