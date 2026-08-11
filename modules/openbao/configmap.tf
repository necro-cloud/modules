// Configurator Script uploaded as a configmap
resource "kubernetes_config_map" "configurator_script" {
  metadata {
    name      = "openbao-configurator-script"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }

  data = {
    "configurator.sh" = var.enable_internal_tls_certificates ? templatefile("${path.module}/config/scripts/configurator.sh", {
      cert_secret_name = kubernetes_manifest.internal_certificate[0].manifest.spec.secretName
    }) : file("${path.module}/config/scripts/configurator_no_tls.sh")
  }
}
