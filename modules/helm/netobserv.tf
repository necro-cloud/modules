# Netobserv Configuration
resource "helm_release" "netobserv" {
  name             = var.netobserv_configuration.name
  namespace        = var.netobserv_configuration.namespace
  repository       = var.netobserv_configuration.repository
  chart            = var.netobserv_configuration.chart
  version          = var.netobserv_configuration.version
  create_namespace = var.netobserv_configuration.create_namespace

  depends_on = [ helm_release.calico, helm_release.cert-manager ]
  timeout = 1800
}
