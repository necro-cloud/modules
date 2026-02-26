output "observability_namespace" {
  description = "Namespace where all components for observability are deployed"
  value = kubernetes_namespace.namespace.metadata[0].name
  depends_on = [ helm_release.grafana ]
}
