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

# -------------- NGINX INGRESS VARIABLES -------------- #

variable "nginx_configuration" {
  description = "Dictionary filled with NGINX Controller Configuration Details"
  type        = map(string)
  default = {
    "name"             = "ingress-nginx"
    "namespace"        = "ingress-nginx"
    "repository"       = "https://kubernetes.github.io/ingress-nginx"
    "chart"            = "ingress-nginx"
    "version"          = "4.12.0"
    "create_namespace" = true
  }
}
