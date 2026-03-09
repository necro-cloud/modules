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
      
      // "Direct" mode sends logs straight to OTel (bypassing Kafka/IPFIX)
      deploymentModel = "Direct"

      agent = {
        type = "eBPF"
        ebpf = {
          // PRIVILEGED: Required for "PacketDrop" to read kernel drop reasons
          privileged = true
          
          // Enable drop detection and TCP round trips metrics
          features = ["PacketDrop", "FlowRTT"] 
          
          // SAMPLING: 25 means 1 in 25 packets
          sampling           = 25
          cacheActiveTimeout = "15s"
          cacheMaxFlows      = 100000
          excludeInterfaces  = ["lo"] // Ignore loopback traffic

          // Resource Constraints
          resources = {
            requests = {
              cpu    = "50m"
              memory = "100Mi"
            }
            limits = {
              cpu    = "500m"  // Hard cap to prevent eBPF compiler spikes
              memory = "512Mi" // Hard cap to prevent leaks
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

      // PROCESSOR: Enrichment settings
      processor = {
        logTypes = "Flows"
        metrics = {
          // Disable agent-side metrics generation to save CPU
          // We will derive metrics from logs in Victoria if needed
          disableAlerts = ["NetObservLokiError", "NetObservNoFlows"] 
        }
      }

      // EXPORT: Pushing to the OTel Collector
      exporters = [
        {
          type = "OpenTelemetry"
          openTelemetry = {
            // 1. POINT THIS TO YOUR OTEL COLLECTOR SERVICE
            // Format: <service-name>.<namespace>.svc.cluster.local
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
