// Setup OpenBao as the Cluster Secret Store
resource "kubernetes_manifest" "cluster_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "openbao"
    }
    spec = {
      refreshInterval = 60
      provider = {
        vault = {
          // Internal HA Service Address
          server  = "https://openbao-internal.${kubernetes_namespace.namespace.metadata[0].name}.svc:8200"
          path    = "secret"
          version = "v2"
          
          // Use TLS to sync secrets to and from the cluster
          caProvider = {
            type      = "Secret"
            name      = kubernetes_manifest.internal_certificate.manifest.spec.secretName
            key       = "ca.crt"
            namespace = kubernetes_namespace.namespace.metadata[0].name
          }

          auth = {
            kubernetes = {
              mountPath = "kubernetes"

              // OpenBao Role to use to authenticate
              role      = "eso-role"
              serviceAccountRef = {

                // Default External Secrets Service Account
                // Also allowed to authenticate with OpenBao
                name      = "external-secrets"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }

  // Ensuring the OpenBao Cluster is ready to go
  depends_on = [kubernetes_job.configurator]

  // Wait for the Store to be valid before proceeding
  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
}
