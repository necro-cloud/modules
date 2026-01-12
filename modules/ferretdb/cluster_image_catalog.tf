resource "kubernetes_manifest" "ferret_cluster_image_catalog" {
  manifest = {
    "apiVersion" : "postgresql.cnpg.io/v1"
    "kind" : "ClusterImageCatalog"
    "metadata" = {
      "name" = "ferret"
    }
    "spec" = {
      "images" = [
        {
          "major" = 16
          "image" = "ghcr.io/ferretdb/postgres-documentdb:16-0.107.0-ferretdb-2.7.0@sha256:43d5279693ed8ad77a18f981af47e5b36b9497bb6caa288093a4e10493ac9e5e"
        },
        {
          "major" = 17
          "image" = "ghcr.io/ferretdb/postgres-documentdb:17-0.107.0-ferretdb-2.7.0@sha256:2386795ec2aa7ae559304361979f1dc5708d383ee9020ae63dadc2940dfe58f7"
        },
      ]
    }
  }
}
