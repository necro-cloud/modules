// OpenBao Deployment Configuration
resource "helm_release" "openbao" {
  name = var.openbao_configuration.name
  repository = var.openbao_configuration.repository
  chart = var.openbao_configuration.chart
  version = var.openbao_configuration.version

  // Deploy it in the same namespace
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

        // Resource Requests and Limits
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

        // Node Affinity for worker nodes
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

        // Topology Spread Constraints
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

       // Environment variable for unsealing the cluster
        extraSecretEnvironmentVars = [
          {
            envName = "OPENBAO_STATIC_UNSEAL_KEY"
            secretName = kubernetes_secret.static_unseal_key.metadata[0].name
            secretKey = "OPENBAO_STATIC_UNSEAL_KEY"
          }
        ]

        // TLS Certificates Mounting
        extraVolumes = [
          {
            type = "secret"
            name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
          }
        ]

        // High availability configuration
        ha = {
          enabled = true
          replicas = var.cluster_size

          // Raft Storage Configuration
          raft = {
            enabled = true
            setNodeId = true

            // Config loaded as a configuration file
            config = templatefile("${path.module}/config/openbao.hcl", {
              namespace = kubernetes_namespace.namespace.metadata[0].name,
              cert_secret_name = kubernetes_manifest.internal_certificate.manifest.spec.secretName
            })
          }
        }

        // Data Storage Configuration
        dataStorage = {
          enabled = true
          size = "5Gi"
          mountPath = "/openbao/data"
          storageClass = "local-path"
        }

        // Enable Auth Delegator
        // for Kubernetes Authentication
        authDelegator = {
          enabled = true
        }

        // Enable permissions for
        // Service Discovery
        serviceAccount = {
          create = true
          serviceDiscovery = {
            enabled = true
          }
        }

        // UI Service
        ui = {
          enabled = true
          serviceType = "ClusterIP"
        }
      }
    })
  ]
}
