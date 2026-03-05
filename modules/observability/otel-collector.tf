resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.145.0"

  namespace = kubernetes_namespace.namespace.metadata[0].name

  values = [
    yamlencode({
      fullnameOverride = "otel-collector"
      
      mode = "daemonset"
      clusterRole = {
        create = true
        rules = [
          {
            apiGroups = [""]
            resources = ["nodes", "nodes/metrics", "nodes/stats", "nodes/proxy", "services", "endpoints", "pods"]
            verbs     = ["get", "list", "watch"]
          },
          {
            apiGroups = ["apps", "extensions"]
            resources = ["replicasets"]
            verbs     = ["get", "list", "watch"]
          }
        ]
      }
      
      // Enable service creation for pushing logs and metrics 
      service = {
        enabled = true
      }

      // Ports for the service to use
      ports = {
        otlp = {
          enabled = true
          containerPort = 4317
          servicePort   = 4317
          hostPort      = 4317
          protocol      = "TCP"
        }
      }

      // Contrib image supports all required features
      image = {
        repository = "otel/opentelemetry-collector-contrib"
      }

      // Inject Node Name as Env Var (Required for Scrape Filtering)
      extraEnvs = [
        {
          name = "K8S_NODE_NAME"
          valueFrom = {
            fieldRef = {
              fieldPath = "spec.nodeName"
            }
          }
        }
      ]

      // Presets for scraping logs and metrics
      presets = {
        // Scrape /var/log/pods
        logsCollection = {
          enabled = true
          includeCollectorLogs = false
        }
        // Scrape Node CPU/RAM/Disk
        hostMetrics = {
          enabled = true
        }
        // Scrape Pod CPU/RAM (Kubelet)
        kubeletMetrics = {
          enabled = true
        }
        // Decorate data with K8s metadata
        kubernetesAttributes = {
          enabled = true
          extractAllPodLabels = true
          extractAllPodAnnotations = true
        }
      }

      // Custom Configuration for receivers
      config = {
        receivers = {
          // OTLP Endpoints to send stuff to this collector
          otlp = {
            protocols = {
              grpc = { endpoint = "0.0.0.0:4317" }
              http = { endpoint = "0.0.0.0:4318" }
            }
          }
          // Scrape annotated pods (prometheus.io/scrape: "true")
          prometheus = {
            config = {
              scrape_configs = [
                {
                  job_name = "kubernetes-pods"
                  honor_labels = true
                  scrape_interval = "30s"
                  body_size_limit = "50MB"

                  // Ignore Self Signed TLS errors while scraping HTTPS endpoints
                  tls_config = {
                    insecure_skip_verify = true
                  }
                  
                  kubernetes_sd_configs = [
                    {
                      role = "pod"
                    }
                  ]
                  relabel_configs = [
                    // Only scrape if annotation exists
                    {
                      source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]
                      action        = "keep"
                      regex         = "true"
                    },
                    // Only scrape pods on the SAME NODE as this collector
                    // This uses the Env Var we injected above.
                    // Note: The double $$ is for Terraform escaping. Result in YAML: ${env:K8S_NODE_NAME}
                    {
                      source_labels = ["__meta_kubernetes_pod_node_name"]
                      action        = "keep"
                      regex         = "$${env:K8S_NODE_NAME}"
                    },
                    // Path override
                    {
                      source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_path"]
                      action        = "replace"
                      target_label  = "__metrics_path__"
                      regex         = "(.+)"
                    },
                    // Port override
                    {
                      source_labels = ["__address__", "__meta_kubernetes_pod_annotation_prometheus_io_port"]
                      action        = "replace"
                      regex         = "([^:]+)(?::\\d+)?;(\\d+)"
                      replacement   = "$1:$2"
                      target_label  = "__address__"
                    },
                    // Add namespace and pod to the metrics data
                    {
                      source_labels = ["__meta_kubernetes_namespace"]
                      action        = "replace"
                      target_label  = "namespace"
                    },
                    {
                      source_labels = ["__meta_kubernetes_pod_name"]
                      action        = "replace"
                      target_label  = "pod"
                    },
                    // Use HTTPS if the scheme asks for it
                    {
                      source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_scheme"]
                      action        = "replace"
                      target_label  = "__scheme__"
                      regex         = "(https?)"
                    }
                  ]
                },
                // Scrape Kubernetes cAdvisor Metrics
                {
                  job_name = "kubelet-cadvisor"
                  scheme   = "https"
                  tls_config = {
                    ca_file              = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                    insecure_skip_verify = true
                  }
                  bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
                  
                  kubernetes_sd_configs = [
                    {
                      role = "node"
                    }
                  ]
                  
                  relabel_configs = [
                    // 1. Only scrape the local node this DaemonSet pod is running on
                    {
                      source_labels = ["__meta_kubernetes_node_name"]
                      action        = "keep"
                      regex         = "$${env:K8S_NODE_NAME}"
                    },
                    // 2. Point directly to the internal cAdvisor endpoint
                    {
                      action       = "replace"
                      target_label = "__metrics_path__"
                      replacement  = "/metrics/cadvisor"
                    }
                  ]
                }
              ]
            }
          }
        }

        // Processors
        processors = {
          batch = {}
          // Strict memory limits for the 512Mi constraint
          memory_limiter = {
            check_interval         = "5s"
            limit_mib              = 400 // Hard cap for the process (leaving 112Mi buffer for OS)
            spike_limit_mib        = 100
          }
          // Tag Netobserv logs appropriately
          "resource/netobserv" = {
            attributes = [
              {
                key    = "log.source"
                value  = "netobserv"
                action = "insert"
              }
            ]
          }

          transform = {
            metric_statements = [
              {
                context = "datapoint"
                statements = [
                  "set(attributes[\"namespace\"], resource.attributes[\"namespace\"]) where attributes[\"namespace\"] == nil and resource.attributes[\"namespace\"] != nil",
                  "set(attributes[\"pod\"], resource.attributes[\"pod\"]) where attributes[\"pod\"] == nil and resource.attributes[\"pod\"] != nil"
                ]
              }
            ]
          }
        }

        // Exporters
        exporters = {
          // Traces -> Debug
          debug = {}
          // Metrics -> VictoriaMetrics
          prometheusremotewrite = {
            endpoint = "http://victoria-metrics-victoria-metrics-single-server:8428/api/v1/write"
          }
          
          // Logs -> VictoriaLogs
          otlphttp = {
            // VictoriaLogs OTLP endpoint
            endpoint = "http://victoria-logs-victoria-logs-single-server:9428/insert/opentelemetry"
            tls = {
              insecure = true
            }
          }
        }

        // Pipelines to pull in data from the cluster
        service = {
          pipelines = {
            metrics = {
              // 'hostmetrics' & 'kubeletstats' come from presets. 'prometheus' is our custom one.
              receivers  = ["otlp", "hostmetrics", "kubeletstats", "prometheus"]
              processors = ["memory_limiter", "k8sattributes", "transform", "batch"]
              exporters  = ["prometheusremotewrite"]
            }
            logs = {
              // 'filelog' comes from the logsCollection preset
              receivers  = ["filelog"]
              processors = ["memory_limiter", "k8sattributes", "batch"]
              exporters  = ["otlphttp"]
            }
            traces = {
              // Defining debug as exporter for traces
              // to ignore traces and catch errors
              // when apps send traces here
              receivers = ["otlp"]
              processors = ["memory_limiter", "batch"]
              exporters = ["debug"] 
            }
            "logs/netobserv" = {
              receivers  = ["otlp"]
              processors = ["memory_limiter", "resource/netobserv", "batch"]
              exporters  = ["otlphttp"]
            }
          }
        }
      }

      // Resource Constraints
      resources = {
        requests = {
          cpu    = "50m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    })
  ]
}
