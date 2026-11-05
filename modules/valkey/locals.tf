locals {
  // Cluster sizing for the Valkey Cluster
  size_lookup = {
    small  = 1
    medium = 2
    large  = 3
  }

  // Ingress IP addresses to be added to the host alias
  ingress_hosts = var.enable_sso ? [
    for ip in data.kubernetes_service_v1.ingress_ip_address[0].status[0].load_balancer[0].ingress : {
      ip        = ip.ip
      hostnames = ["${var.sso_host_name}.${var.domain}"]
    }
  ] : []
}
