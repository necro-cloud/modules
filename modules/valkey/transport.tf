// Server Transport Resource for HTTPS Backend Connections
resource "kubernetes_manifest" "transport" {
  count = var.enable_ui ? 1 : 0
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "transport"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      serverName = "${kubernetes_service.ui_service[0].metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
      rootCAs = var.enable_internal_tls_certificates ? [
        {
          secret = kubernetes_manifest.internal_certificate[0].manifest.spec.secretName
        }
      ] : []
    }
  }
}
