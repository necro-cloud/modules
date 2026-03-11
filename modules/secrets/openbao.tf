resource "helm_release" "openbao" {
  name = var.openbao_configuration.name
  repository = var.openbao_configuration.repository
  chart = var.openbao_configuration.chart
  version = var.openbao_configuration.version
  
  namespace = kubernetes_namespace.namespace.metadata[0].name
  create_namespace = false

  wait = true
  timeout = 600

  values = [
    yamlencode({
      global = {
        enabled = true
        tlsDisable = false
      }

      server = {

        resources = {
          requests = {
            memory = "256Mi"
            cpu    = "100m"
          }
          limits = {
            memory = "512Mi"
            cpu    = "500m"
          }
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
        
        topologySpreadConstraints = [
          {
            maxSkew           = 1
            topologyKey       = "kubernetes.io/hostname"
            whenUnsatisfiable = "DoNotSchedule"
            labelSelector = {
              matchLabels = {
                "app.kubernetes.io/name"     = "openbao"
                "app.kubernetes.io/instance" = "openbao"
                "component"                  = "server"
              }
            }
          }
        ]
 
        extraSecretEnvironmentVars = [
          {
            envName = "OPENBAO_STATIC_UNSEAL_KEY"
            secretName = kubernetes_secret.static_unseal_key.metadata[0].name
            secretKey = "OPENBAO_STATIC_UNSEAL_KEY"
          }
        ]

        extraVolumes = [
          {
            type = "secret"
            name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
          }
        ]

        ha = {
          enabled = true
          replicas = var.cluster_size
          raft = {
            enabled = true
            setNodeId = true

            config = templatefile("${path.module}/config/openbao.hcl", {
              namespace = kubernetes_namespace.namespace.metadata[0].name,
              cert_secret_name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
            })
          }
        }

        dataStorage = {
          enabled = true
          size = "5Gi"
          mountPath = "/openbao/data"
          storageClass = "local-path"
        }

        authDelegator = {
          enabled = true
        }

        serviceAccount = {
          create = true
          serviceDiscovery = {
            enabled = true
          }
        }

        ui = {
          enabled = true
          serviceType = "ClusterIP"
        }
      }
    })
  ]
}
