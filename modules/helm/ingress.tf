# Traefik Ingress Controller Configuration
resource "helm_release" "traefik" {
  name             = var.traefik_configuration.name
  namespace        = var.traefik_configuration.namespace
  repository       = var.traefik_configuration.repository
  chart            = var.traefik_configuration.chart
  version          = var.traefik_configuration.version
  create_namespace = var.traefik_configuration.create_namespace

  values = [
    yamlencode({
      nodeSelector = {
        server = var.server_node_selector
      }

      providers = {
        kubernetesCRD = {
          enabled = true
          allowCrossNamespace = true 
        }
        kubernetesIngress = {
          enabled      = true
          ingressClass = "traefik"
          publishedService = {
            enabled = true
          }
        }
      }

      ports = {
        web = {
          http = {
            redirections = {
              entryPoint = {
                to     = "websecure"
                scheme = "https"
              }
            }
          }
        }
        websecure = {
          expose = {
            default = true
          }
          exposedPort = 443
        }
      }

      logs = {
        general = {
          level  = "DEBUG"
        }
      }

      
      additionalArguments = [
        "--serverstransport.insecureSkipVerify=true"
      ]

      ingressClass = {
        enabled        = true
        isDefaultClass = true
        name           = "traefik"
      }
    })
  ]

  depends_on = [helm_release.calico]
  timeout    = 1800
}
