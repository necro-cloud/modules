# -------------- CERT MANAGER HELM CHART VARIABLES -------------- #
variable "cert_manager_configuration" {
  description = "Dictionary filled with Cert Manager Operator Configuration Details"
  type        = map(string)
  default = {
    "name"             = "cert-manager"
    "namespace"        = "cert-manager"
    "repository"       = "https://charts.jetstack.io"
    "chart"            = "cert-manager"
    "version"          = "v1.17.1"
    "create_namespace" = true
  }
}

# -------------- CERT MANAGER HELM CHART VARIABLES -------------- #
variable "cluster_issuer_name" {
  description = "Name of the Self Signed Cluster Issuer"
  type        = string
  default     = "private-cluster-issuer"
}
