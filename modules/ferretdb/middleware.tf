// Middleware 1: The Rewrite logic
resource "kubernetes_manifest" "middleware_rewrite" {
  count = var.enable_ui ? 1 : 0
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "rewrite"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      replacePathRegex = {
        regex       = "^/(.*)$"
        replacement = "/$1"
      }
    }
  }
}

// Middleware 2: The Buffering logic
resource "kubernetes_manifest" "middleware_buffering" {
  count = var.enable_ui ? 1 : 0
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "buffering"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      buffering = {
        maxRequestBodyBytes = 524288000
      }
    }
  }
}
