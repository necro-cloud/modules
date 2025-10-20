// Calico Configuration
resource "helm_release" "calico" {
  name             = var.calico_configuration.name
  namespace        = var.calico_configuration.namespace
  repository       = var.calico_configuration.repository
  chart            = var.calico_configuration.chart
  version          = var.calico_configuration.version
  create_namespace = var.calico_configuration.create_namespace

  set = [
    {
      name  = "nodeSelector.server"
      value = var.server_node_selector
    },
    {
      name  = "installation.calicoNetwork.ipPools[0].cidr"
      value = "10.42.0.0/16"
    },
    {
      name  = "installation.calicoNetwork.ipPools[0].natOutgoing"
      value = "Enabled"
    },
    {
      name  = "installation.calicoNetwork.ipPools[0].ipipMode"
      value = "Always"
    },
    {
      name  = "installation.calicoNetwork.ipPools[0].nodeSelector"
      value = "all()"
    },
    {
      name  = "installation.calicoNetwork.policy.type"
      value = "Calico"
    }
  ]
}
