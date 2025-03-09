output "cluster-issuer-name" {
  description = "Name of the Cluster Issuer to be used for further certificate deployments"
  value       = kubernetes_manifest.cluster_self_signed_issuer.manifest.metadata.name
}
