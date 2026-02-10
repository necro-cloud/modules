resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.145.0"

  namespace = kubernetes_namespace.namespace.metadata[0].name

  values = [
    yamlencode({
      mode = "daemonset"

      # Contrib image supports all required features
      image = {
        repository = "otel/opentelemetry-collector-contrib"
      }

      # Inject Node Name as Env Var (Required for Scrape Filtering)
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

      # Presets for scraping logs and metrics
      presets = {
        # Scrape /var/log/pods
        logsCollection = {
          enabled = true
          includeCollectorLogs = false
        }
        # Scrape Node CPU/RAM/Disk
        hostMetrics = {
          enabled = true
        }
        # Scrape Pod CPU/RAM (Kubelet)
        kubeletMetrics = {
          enabled = true
        }
        # Decorate data with K8s metadata
        kubernetesAttributes = {
          enabled = true
          extractAllPodLabels = true
          extractAllPodAnnotations = true
        }
      }

      # Custom Configuration for receivers
      config = {
        receivers = {
          # Scrape annotated pods (prometheus.io/scrape: "true")
          prometheus = {
            config = {
              scrape_configs = [
                {
                  job_name = "kubernetes-pods"
                  scrape_interval = "30s"
                  kubernetes_sd_configs = [
                    {
                      role = "pod"
                    }
                  ]
                  relabel_configs = [
                    # Only scrape if annotation exists
                    {
                      source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]
                      action        = "keep"
                      regex         = "true"
                    },
                    # Only scrape pods on the SAME NODE as this collector
                    # This uses the Env Var we injected above.
                    # Note: The double $$ is for Terraform escaping. Result in YAML: ${env:K8S_NODE_NAME}
                    {
                      source_labels = ["__meta_kubernetes_pod_node_name"]
                      action        = "keep"
                      regex         = "$${env:K8S_NODE_NAME}"
                    },
                    # Path override
                    {
                      source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_path"]
                      action        = "replace"
                      target_label  = "__metrics_path__"
                      regex         = "(.+)"
                    },
                    # Port override
                    {
                      source_labels = ["__address__", "__meta_kubernetes_pod_annotation_prometheus_io_port"]
                      action        = "replace"
                      regex         = "([^:]+)(?::\\d+)?;(\\d+)"
                      replacement   = "$1:$2"
                      target_label  = "__address__"
                    }
                  ]
                }
              ]
            }
          }
        }

        # Processors
        processors = {
          batch = {}
          # Strict memory limits for the 512Mi constraint
          memory_limiter = {
            check_interval         = "5s"
            limit_mib              = 400 # Hard cap for the process (leaving 112Mi buffer for OS)
            spike_limit_mib        = 100
          }
        }

        # Exporters
        exporters = {
          # Metrics -> VictoriaMetrics
          prometheusremotewrite = {
            endpoint = "http://victoria-metrics-victoria-metrics-single-server:8428/api/v1/write"
          }
          
          # Logs -> VictoriaLogs
          otlphttp = {
            # VictoriaLogs OTLP endpoint
            endpoint = "http://victoria-logs-victoria-logs-single-server:9428/insert/opentelemetry/v1/logs"
            tls = {
              insecure = true
            }
          }
        }

        # Pipelines to pull in data from the cluster
        service = {
          pipelines = {
            metrics = {
              # 'hostmetrics' & 'kubeletstats' come from presets. 'prometheus' is our custom one.
              receivers  = ["otlp", "hostmetrics", "kubeletstats", "prometheus"]
              processors = ["memory_limiter", "k8sattributes", "batch"]
              exporters  = ["prometheusremotewrite"]
            }
            logs = {
              # 'filelog' comes from the logsCollection preset
              receivers  = ["otlp", "filelog"]
              processors = ["memory_limiter", "k8sattributes", "batch"]
              exporters  = ["otlphttp"]
            }
            traces = {
              # Defining debug as exporter for traces
              # to ignore traces and catch errors
              # when apps send traces here
              receivers = ["otlp"]
              processors = ["memory_limiter", "batch"]
              exporters = ["debug"] 
            }
          }
        }
      }

      # Resource Constraints
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

      # Placement (Pinned to Worker Nodes)
      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  {
                    key      = "worker"
                    operator = "Exists"
                  }
                ]
              }
            ]
          }
        }
      }
    })
  ]
}
