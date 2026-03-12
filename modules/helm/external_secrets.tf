# External Secrets Operator Configuration
resource "helm_release" "external_secrets" {
  name             = var.external_secrets_configuration.name
  namespace        = var.external_secrets_configuration.namespace
  repository       = var.external_secrets_configuration.repository
  chart            = var.external_secrets_configuration.chart
  version          = var.external_secrets_configuration.version
  create_namespace = var.external_secrets_configuration.create_namespace

  depends_on = [ helm_release.calico ]
  timeout = 1800
}
