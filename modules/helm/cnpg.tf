// Cloud Native PG Operator Configuration
resource "helm_release" "cnpg" {
  name             = var.cnpg_configuration.name
  namespace        = var.cnpg_configuration.namespace
  repository       = var.cnpg_configuration.repository
  chart            = var.cnpg_configuration.chart
  version          = var.cnpg_configuration.version
  create_namespace = var.cnpg_configuration.create_namespace
}

// Barman Cloud Plugin installation (no helm chart yet)
resource "null_resource" "barman_plugin" {
  triggers = {
    "cnpg_chart_id"         = helm_release.cnpg.id
    "cert_manager_chart_id" = helm_release.cert-manager.id
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/${var.barman_cloud_plugin_version}/manifest.yaml"
  }
}
