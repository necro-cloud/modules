output "namespace" {
  description = "Namespace where the PostgreSQL Database is deployed in"
  value       = kubernetes_namespace.namespace.metadata[0].name
}

output "server-certificate-authority" {
  description = "Certificate Authority being used with PostgreSQL Database"
  value       = kubernetes_manifest.server_certificate_authority.manifest.spec.secretName
}
