output "valkey_namespace" {
  description = "Namespace to be used for deploying Valkey Cache Solution"
  value = kubernetes_namespace.namespace.metadata[0].name
}

output "valkey_certificates_name" {
  description = "Name of the Internal Certificate to be associated with Valkey Cache Solution"
  value = kubernetes_manifest.internal_certificate.manifest.spec.secretName
}

output "valkey_credentials_name" {
  description = "Name of the secret where credentials for Valkey Cache Solution is stored"
  value = kubernetes_manifest.valkey_credentials_sync.object.spec.target.name
}
