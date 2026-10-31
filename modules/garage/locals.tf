locals {
  // Garage Configurator Options
  configurator_options = {
    adminApiUrl                 = "${local.garage_scheme}://garage-0.${kubernetes_service.garage-headless.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local:${local.garage_admin_port}"
    k8sClusterName              = var.garage_cluster_name
    k8sClusterNamespace         = kubernetes_namespace.namespace.metadata[0].name
    region                      = var.garage_region
    desiredReplicas             = local.size_lookup[var.cluster_size]
    nodeTags                    = var.garage_node_tags
    buckets                     = var.required_buckets
    storagePerNodeInGBs         = var.required_storage
    accessKeysSecretAnnotations = {}
    accessKeysSecretLabels = {
      app            = var.app_name
      component      = "secret"
      "generated-by" = "garage-configurator"
    }
    accessKeys = var.required_access_keys
  }

  // Garage TLS Settings depending on enablement of internal TLS certificates
  garage_scheme     = var.enable_internal_tls_certificates ? "https" : "http"
  garage_port       = var.enable_internal_tls_certificates ? 3940 : 3900
  garage_admin_port = var.enable_internal_tls_certificates ? 3943 : 3903
  ui_port           = var.enable_internal_tls_certificates ? 8443 : 8080

  // Garage Cluster Sizing
  size_lookup = {
    small  = 1
    medium = 3
    large  = 5
  }

  
  // Ingress IP addresses to be added to the host alias
  ingress_hosts = var.enable_sso ? [
    for ip in data.kubernetes_service_v1.ingress_ip_address[0].status[0].load_balancer[0].ingress : {
      ip        = ip.ip
      hostnames = ["${var.sso_host_name}.${var.domain}"]
    }
  ] : []
}
