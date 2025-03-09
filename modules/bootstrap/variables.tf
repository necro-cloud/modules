# -------------- KUBERNETES REFLECTOR VARIABLES -------------- #

variable "reflector_configuration" {
  description = "Dictionary filled with Kubernetes Reflector Configuration Details"
  type        = map(string)
  default = {
    "name"             = "reflector"
    "namespace"        = "reflector"
    "repository"       = "https://emberstack.github.io/helm-charts"
    "chart"            = "reflector"
    "version"          = "v9.0.320"
    "create_namespace" = true
  }
}
