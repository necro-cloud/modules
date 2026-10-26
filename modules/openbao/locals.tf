locals {
  openbao_configuration = var.enable_internal_tls_certificates ? var.cluster_size != "small" ? templatefile("${path.module}/config/openbao/openbao.hcl", {
    namespace        = kubernetes_namespace.namespace.metadata[0].name,
    cert_secret_name = kubernetes_manifest.internal_certificate[0].manifest.spec.secretName
    enable_ui        = var.enable_ui
    }) : templatefile("${path.module}/config/openbao/openbao_single_node.hcl", {
    namespace        = kubernetes_namespace.namespace.metadata[0].name,
    cert_secret_name = kubernetes_manifest.internal_certificate[0].manifest.spec.secretName
    enable_ui        = var.enable_ui
    }) : var.cluster_size != "small" ? templatefile("${path.module}/config/openbao/openbao_no_tls.hcl", {
    namespace = kubernetes_namespace.namespace.metadata[0].name,
    enable_ui = var.enable_ui
    }) : templatefile("${path.module}/config/openbao/openbao_no_tls_single_node.hcl", {
    namespace = kubernetes_namespace.namespace.metadata[0].name,
    enable_ui = var.enable_ui
  })
  size_lookup = {
    small  = 1
    medium = 2
    large  = 3
  }
  cluster_secret_store_name = var.enable_internal_tls_certificates ? kubernetes_manifest.cluster_store[0].manifest.metadata.name : kubernetes_manifest.cluster_store_no_tls[0].manifest.metadata.name


  ingress_hosts = [
    for ip in data.kubernetes_service_v1.ingress_ip_address.status[0].load_balancer[0].ingress : {
      ip        = ip.ip
      hostnames = ["${var.sso_host_name}.${var.domain}"]
    }
  ]
}
