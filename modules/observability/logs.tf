resource "helm_release" "logs" {
  name = "victoria-logs"
  repository = "https://victoriametrics.github.io/helm-charts/"
  chart = "victoria-logs-single"
  version = "0.11.26"

  namespace = kubernetes_namespace.namespace.metadata[0].name

  values = [
    yamlencode({
      server = {
        replicaCount = 1
        retentionPeriod = "7d"

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

        persistentVolume = {
          enabled      = true
          accessModes  = ["ReadWriteOnce"]
          size         = "10Gi"
          storageClassName = "local-path"
        }

        podLabels = {
          app = var.app_name
          component = "pod"
        }
          
        affinity =  {
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
      }
    })
  ]
}
