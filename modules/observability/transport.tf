// Server Transport Resource for HTTPS Backend Connections
resource "kubernetes_manifest" "transport" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "transport"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      insecureSkipVerify = true
      rootCAs = [
        {
          secret = kubernetes_manifest.internal_certificate.manifest.spec.secretName
        }
      ]
    }
  }
}
