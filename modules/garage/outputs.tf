# // Garage Namespace Output
# output "garage_namespace" {
#   value       = kubernetes_namespace.namespace.metadata[0].name
#   description = "Namespace where Garage Storage Solution is deployed in"
#   depends_on  = [kubernetes_job.configurator]
# }

# // Garage Internal Certificate Name Output
# output "garage_internal_certificate_secret" {
#   value       = kubernetes_manifest.internal_certificate.manifest.spec.secretName
#   description = "Secret name where the Internal Certificate for Garage is stored in"
#   depends_on  = [kubernetes_job.configurator]
# }
