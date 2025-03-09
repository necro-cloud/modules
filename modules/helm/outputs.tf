output "minio-operator-namespace" {
  description = "Namespace where the MinIO Operator is deployed in"
  value       = helm_release.minio.namespace
}
