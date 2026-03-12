output "cluster_secret_store_name" {
  description = "Name of the cluster secret store to be used for pulling and pushing secrets to OpenBao"
  value = kubernetes_manifest.cluster_store.manifest.metadata.name
}
