# Kubernetes Reflector Configuration
resource "helm_release" "reflector" {
  name             = var.reflector_configuration.name
  namespace        = var.reflector_configuration.namespace
  repository       = var.reflector_configuration.repository
  chart            = var.reflector_configuration.chart
  version          = var.reflector_configuration.version
  create_namespace = var.reflector_configuration.create_namespace

  set = [
    {
      name  = "nodeSelector.server"
      value = var.server_node_selector
    }
  ]

  depends_on = [ helm_release.calico ]
  timeout = 1800
}
