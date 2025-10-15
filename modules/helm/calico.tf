// Calico Configuration
resource "helm_release" "cert-manager" {
  name       = var.calico_configuration.name
  repository = var.calico_configuration.repository
  chart      = var.calico_configuration.chart
  version    = var.calico_configuration.version

  set = [
    var.node_selector
  ]
}
