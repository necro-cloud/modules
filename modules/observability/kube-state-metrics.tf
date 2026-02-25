resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "7.1.0"

  namespace  = kubernetes_namespace.namespace.metadata[0].name 

  values = [
    yamlencode({
      podAnnotations = {
        "prometheus.io/scrape" = "true"
        "prometheus.io/port"   = "8080"
      }
    })
  ]
}
