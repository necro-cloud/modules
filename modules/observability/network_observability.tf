resource "kubernetes_manifest" "network_observability" {
	manifest = {
    apiVersion = "flows.netobserv.io/v1beta2"
    kind       = "FlowCollector"
    metadata = {
      // The operator expects this specific name
      name = "cluster"
    }
    spec = {
      namespace = kubernetes_namespace.namespace.metadata[0].name
      
      // "Direct" mode sends logs straight to OTel
      deploymentModel = "Direct"

      agent = {
        type = "eBPF"
        ebpf = {
          // Required for "PacketDrop" to read kernel drop reasons
          privileged = true
          
          // Enable drop detection and TCP round trips metrics
          features = ["PacketDrop", "FlowRTT"] 
          
          // 25 means 1 in 25 packets
          sampling           = 25
          cacheActiveTimeout = "15s"
          cacheMaxFlows      = 100000

          // Ignore loopback traffic
          excludeInterfaces  = ["lo"]

          // Resource Constraints
          resources = {
            requests = {
              cpu    = "50m"
              memory = "100Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }

      // Disable default stack for the netobserv instance
      loki = {
        enable = false
      }
      prometheus = {
        querier = {
          enable = false
        }
      }
      consolePlugin = {
        enable = false
      }

      //  Enrichment settings
      processor = {
        logTypes = "Flows"
        metrics = {
          // Disable agent-side metrics generation to save CPU
          disableAlerts = ["NetObservLokiError", "NetObservNoFlows"] 
        }
      }

      // Pushing metrics to the OTel Collector
      exporters = [
        {
          type = "OpenTelemetry"
          openTelemetry = {
            targetHost = "otel-collector.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local"
            targetPort = 4317
            protocol   = "grpc"
            
            logs = {
              enable = true
              pushTimeInterval = "20s"
              expiryTime       = "2m"
            }
            
            metrics = {
              enable = true
            }
            tls = {
              enable = false
              insecureSkipVerify = true
            }
          }
        }
      ]
    }
  }

  depends_on = [ helm_release.otel_collector ]  
}
