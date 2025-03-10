// Cloud Native PG Operator Configuration
resource "helm_release" "cnpg" {
  name             = var.cnpg_configuration.name
  namespace        = var.cnpg_configuration.namespace
  repository       = var.cnpg_configuration.repository
  chart            = var.cnpg_configuration.chart
  version          = var.cnpg_configuration.version
  create_namespace = var.cnpg_configuration.create_namespace
}
