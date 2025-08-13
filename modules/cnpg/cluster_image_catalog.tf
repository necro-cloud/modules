resource "kubernetes_manifest" "cluster_image_catalog" {
  manifest = {
    "apiVersion" : "postgresql.cnpg.io/v1"
    "kind" : "ClusterImageCatalog"
    "metadata" = {
      "name" = "catalog"
    }
    "spec" = {
      "images" = [
        {
          "major" = 16
          "image" = "ghcr.io/cloudnative-pg/postgresql:16.9-22-bookworm@sha256:cf18ae5bff664c2d3153f1696daf8a131e6b439690ddf16f7741a6fc6868cb03"
        },
        {
          "major" = 17
          "image" = "ghcr.io/cloudnative-pg/postgresql:17.5-22-bookworm@sha256:89e09df1966a124cd8e015d16f8e888809e5560a3df2900c91433f73176a0b2d"
        },
        {
          "major" = 18
          "image" = "ghcr.io/cloudnative-pg/postgresql:18beta2-4-bookworm@sha256:6b1c2b1d511d4896c192e232755961cf0f2bc174023187204978a8048bb80e27"
        },
      ]
    }
  }
}
