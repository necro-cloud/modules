output "namespace" {
  description = "Namespace where MinIO is deployed"
  value       = kubernetes_namespace.namespace.metadata[0].name
}

output "certificate-authority-name" {
  description = "Certificate Authority Name for the MinIO Tenant"
  value       = kubernetes_manifest.certificate_authority.manifest.spec.secretName
}

output "postgres-user-minio-configuration" {
  description = "PostgreSQL Configuration for storing PITR backups"
  value       = kubernetes_secret.postgres_user_configuration.metadata[0].name
}

output "postgres-backup-bucket" {
  description = "Bucket to be used for storing PostgreSQL PITR Backups"
  value       = var.postgresql_backup_bucket
}
