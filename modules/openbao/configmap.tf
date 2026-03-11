// Configurator Script uploaded as a configmap
resource "kubernetes_config_map" "configurator_script" {
  metadata {
    name = "openbao-configurator-script"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }

  data = {
    "configurator.sh" = templatefile("${path.module}/config/configurator.sh", {
      cert_secret_name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
    })
  }
}
