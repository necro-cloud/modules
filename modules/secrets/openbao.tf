resource "helm_release" "openbao" {
  name = "openbao"
  repository = "https://openbao.github.io/openbao-helm"
  chart = "openbao"
  version = "0.25.6"
  
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
          replicas = 3
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
