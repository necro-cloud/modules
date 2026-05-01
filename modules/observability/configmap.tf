# ConfigMap for setting up the proto file for querying Goldmane GRPC API
resource "kubernetes_config_map" "goldmane_api_proto" {
  metadata {
    name      = "goldmane-api-proto"
    namespace = "calico-system"
  }

  data = {
    "api.proto" = file("${path.module}/proto/api.proto")
  }
}
