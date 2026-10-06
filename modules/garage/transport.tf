// Server Transport Resource for Garage API access
resource "kubernetes_manifest" "api_transport" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "api-transport"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      serverName = "garage-service.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
      rootCAs = var.enable_internal_tls_certificates ? [
        {
          secret = kubernetes_manifest.internal_certificate[0].manifest.spec.secretName
        }
      ] : []
    }
  }
}

// Server Transport for the UI Service
resource "kubernetes_manifest" "ui_transport" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "ui-transport"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      serverName = "garage-ui.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
      rootCAs = var.enable_internal_tls_certificates ? [
        {
          secret = kubernetes_manifest.ui_internal_certificate[0].manifest.spec.secretName
        }
      ] : []
    }
  }
}
