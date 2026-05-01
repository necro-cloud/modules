# Print out the network flow logs to stdout from Goldmane API
resource "kubernetes_deployment" "goldmane_otel_adapter" {
  metadata {
    name      = "goldmane-otel-adapter"
    namespace = "calico-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "goldmane-otel-adapter"
      }
    }

    template {
      metadata {
        labels = {
          app = "goldmane-otel-adapter"
        }
      }

      spec {
        container {
          name    = "scraper"
          image   = "alpine:latest"
          command = ["/bin/sh", "-c"]
          
          args = [
            <<-EOF
            # Install jq and curl
            apk add --no-cache jq curl

            # Download and extract the grpcurl binary directly into our path
            curl -sL https://github.com/fullstorydev/grpcurl/releases/download/v1.9.3/grpcurl_1.9.3_linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin grpcurl

            # Run the stream and pipe it to jq
            grpcurl -import-path /etc/proto -proto api.proto \
              -cacert /etc/pki/tls/certs/tigera-ca-bundle.crt \
              -cert /goldmane-key-pair/tls.crt \
              -key /goldmane-key-pair/tls.key \
              -d '{"start_time_gte": 0, "aggregation_interval": 5}' \
              goldmane.calico-system.svc.cluster.local:7443 goldmane.Flows/Stream \
              | jq --unbuffered -c '.'
            EOF
          ]

          volume_mount {
            name       = "proto-file"
            mount_path = "/etc/proto"
            read_only  = true
          }

          volume_mount {
            name       = "goldmane-ca-bundle"
            mount_path = "/etc/pki/tls/certs"
            read_only  = true
          }

          volume_mount {
            name       = "goldmane-key-pair"
            mount_path = "/goldmane-key-pair"
            read_only  = true
          }
        }

        volume {
          name = "proto-file"
          config_map {
            name = kubernetes_config_map.goldmane_api_proto.metadata[0].name
          }
        }

        volume {
          name = "goldmane-ca-bundle"
          config_map {
            name = "goldmane-ca-bundle"
          }
        }

        volume {
          name = "goldmane-key-pair"
          secret {
            secret_name = "goldmane-key-pair"
          }
        }
      }
    }
  }
}
