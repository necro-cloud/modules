// MinIO Operator Configuration
resource "helm_release" "minio" {
  name             = var.minio_operator_configuration.name
  namespace        = var.minio_operator_configuration.namespace
  repository       = var.minio_operator_configuration.repository
  chart            = var.minio_operator_configuration.chart
  version          = var.minio_operator_configuration.version
  create_namespace = var.minio_operator_configuration.create_namespace
}
