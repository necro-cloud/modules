# -------------- KUBERNETES REFLECTOR VARIABLES -------------- #
variable "reflector_configuration" {
  description = "Dictionary filled with Kubernetes Reflector Configuration Details"
  type        = map(string)
  default = {
    "name"             = "reflector"
    "namespace"        = "reflector"
    "repository"       = "https://emberstack.github.io/helm-charts"
    "chart"            = "reflector"
    "version"          = "v9.1.35"
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
    "version"          = "4.13.3"
    "create_namespace" = true
  }
}

# -------------- CERT MANAGER HELM CHART VARIABLES -------------- #
variable "cert_manager_configuration" {
  description = "Dictionary filled with Cert Manager Operator Configuration Details"
  type        = map(string)
  default = {
    "name"             = "cert-manager"
    "namespace"        = "cert-manager"
    "repository"       = "https://charts.jetstack.io"
    "chart"            = "cert-manager"
    "version"          = "v1.19.0"
    "create_namespace" = true
  }
}

# --------------- MINIO OPERATOR VARIABLES --------------- #
variable "enable_minio" {
  description = "To enable MinIO Deployment or not"
  type        = bool
  default     = false
}

variable "minio_operator_configuration" {
  description = "Dictionary filled with MinIO Operator Configuration Details"
  type        = map(string)
  default = {
    "name"             = "minio-operator"
    "namespace"        = "minio-operator"
    "repository"       = "https://operator.min.io"
    "chart"            = "operator"
    "version"          = "7.0.0"
    "create_namespace" = true
  }
}

# --------------- CLOUDNATIVE PG OPERATOR VARIABLES --------------- #
variable "cnpg_configuration" {
  description = "Dictionary filled with Cloud Native PG Operator Configuration Details"
  type        = map(string)
  default = {
    "name"             = "cnpg"
    "namespace"        = "cnpg-system"
    "repository"       = "https://cloudnative-pg.github.io/charts"
    "chart"            = "cloudnative-pg"
    "version"          = "v0.26.0"
    "create_namespace" = true
  }
}

variable "cnpg_barman_configuration" {
  description = "Dictionary filled with Cloud Native PG Barman Configuration Details"
  type        = map(string)
  default = {
    "name"       = "cnpg-barman"
    "namespace"  = "cnpg-system"
    "repository" = "https://cloudnative-pg.github.io/charts"
    "chart"      = "plugin-barman-cloud"
    "version"    = "v0.2.0"
  }
}

# --------------- CALICO OPERATOR VARIABLES --------------- #
variable "calico_configuration" {
  description = "Dictionary filled with Calico Configuration Details"
  type        = map(string)
  default = {
    "name"             = "tigera-operator"
    "namespace"        = "tigera-operator"
    "repository"       = "https://docs.tigera.io/calico/charts"
    "chart"            = "tigera-operator"
    "version"          = "v3.30.3"
    "create_namespace" = true
  }
}
