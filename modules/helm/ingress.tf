// NGINX Ingress Controller Configuration
resource "helm_release" "nginx" {
  name             = var.nginx_configuration.name
  namespace        = var.nginx_configuration.namespace
  repository       = var.nginx_configuration.repository
  chart            = var.nginx_configuration.chart
  version          = var.nginx_configuration.version
  create_namespace = var.nginx_configuration.create_namespace

  set = [var.node_selector]
}
