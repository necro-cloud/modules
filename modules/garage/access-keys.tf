resource "kubernetes_manifest" "push_access_keys" {
  for_each = { for key in var.required_access_keys : key.name => key }
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-access-key-${each.key}"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      deletionPolicy  = "None"
      secretStoreRefs = [{
        name = var.cluster_secret_store_name
        kind = "ClusterSecretStore"
      }]
      selector = {
        secret = {
          name = "${each.key}-credentials"
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/access-key/${each.key}"
            }
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_job.configurator]
}
