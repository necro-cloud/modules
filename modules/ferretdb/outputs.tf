output "namespace" {
  description = "Namespace where the PostgreSQL Database is deployed in"
  value       = kubernetes_namespace.namespace.metadata[0].name
  depends_on  = [ubernetes_manifest.ferret_database]
}
