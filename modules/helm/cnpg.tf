// Cloud Native PG Operator Configuration
resource "helm_release" "cnpg" {
  name             = var.cnpg_configuration.name
  namespace        = var.cnpg_configuration.namespace
  repository       = var.cnpg_configuration.repository
  chart            = var.cnpg_configuration.chart
  version          = var.cnpg_configuration.version
  create_namespace = var.cnpg_configuration.create_namespace

  set = [
    {
      name  = "nodeSelector.server"
      value = var.server_node_selector
    }
  ]
}

// Barman Cloud Plugin installation
resource "helm_release" "cnpg_barman_plugin" {
  name       = var.cnpg_barman_configuration.name
  namespace  = var.cnpg_barman_configuration.namespace
  repository = var.cnpg_barman_configuration.repository
  chart      = var.cnpg_barman_configuration.chart
  version    = var.cnpg_barman_configuration.version

  set = [
    {
      name  = "nodeSelector.server"
      value = var.server_node_selector
    }
  ]

  depends_on = [helm_release.cnpg, helm_release.cert-manager]
}
