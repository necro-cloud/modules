resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana-community.github.io/helm-charts"
  chart      = "grafana"
  version    = "11.1.7"

  namespace = kubernetes_namespace.namespace.metadata[0].name

  values = [
    yamlencode({
      adminUser     = "admin"
      adminPassword = "admin" 

      # Automatically install the VictoriaMetrics Logs plugin for native VictoriaLogs support
      plugins = [
        "victoriametrics-logs-datasource"
      ]

      # Provisioning of datasources during deployment
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "VictoriaMetrics"
              type      = "prometheus"
              url       = "http://victoria-metrics-victoria-metrics-single-server:8428"
              access    = "proxy"
              isDefault = true
            },
            {
              name   = "VictoriaLogs"
              type   = "victoriametrics-logs-datasource"
              url    = "http://victoria-logs-victoria-logs-single-server:9428"
              access = "proxy"
            }
          ]
        }
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }

      # Persistence for dashboards, settings, and downloaded plugins
      persistence = {
        enabled          = true
        accessModes      = ["ReadWriteOnce"]
        size             = "5Gi"
        storageClassName = "local-path"
      }

      podLabels = {
        app       = var.app_name
        component = "dashboard"
      }

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

  depends_on = [
    helm_release.metrics,
    helm_release.logs
  ]
}
