// Cert Manager Operator Configuration
resource "helm_release" "cert-manager" {
  name             = var.cert_manager_configuration.name
  namespace        = var.cert_manager_configuration.namespace
  repository       = var.cert_manager_configuration.repository
  chart            = var.cert_manager_configuration.chart
  version          = var.cert_manager_configuration.version
  create_namespace = var.cert_manager_configuration.create_namespace

  set = [
    {
      name  = "crds.enabled"
      value = true
    },
    {
      name  = "global.nodeSelector.server"
      value = var.server_node_selector
    },
    {
      name = "extraArgs[0]"
      value = "--dns01-recursive-nameservers-only"
    },
    {
      name = "extraArgs[1]"
      value = "--dns01-recursive-nameservers=1.1.1.1:53,1.0.0.1:53"
    }
  ]
}
