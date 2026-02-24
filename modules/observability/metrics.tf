resource "helm_release" "metrics" {
  name = "victoria-metrics"
  repository = "https://victoriametrics.github.io/helm-charts/"
  chart = "victoria-metrics-single"
  version = "0.30.0"

  namespace = kubernetes_namespace.namespace.metadata[0].name

  values = [
    yamlencode({
      server = {
        
        extraArgs = {
          "maxLabelValueLen" = "8192"
        }        

        replicaCount = 1
        retentionPeriod = "7d"

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "768Mi"
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
