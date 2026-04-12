# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying Valkey Cache Solution"
  type        = string
  default     = "valkey"
}

variable "organization_name" {
  description = "Organization name for deploying Valkey Cache Solution"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying Valkey Cache Solution"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying Valkey Cache Solution"
  type        = string
  default     = "valkey"
}

variable "observability_namespace" {
  description = "Namespace where all components for observability are deployed"
  type        = string
  nullable    = false
}

# --------------- CLUSTER SECRET STORE VARIABLES --------------- #
variable "cluster_secret_store_name" {
  description = "Name of the cluster secret store to be used for pulling and pushing secrets to OpenBao"
  type        = string
  nullable    = false
}

# --------------- CERTIFICATE VARIABLES --------------- #
variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = false
}

variable "certificate_authority_name" {
  description = "Name of the Certificate Authority to be associated with Valkey Cache Solution"
  type        = string
  default     = "valkey-certificate-authority"
}

variable "issuer_name" {
  description = "Name of the Issuer to be associated with Valkey Cache Solution"
  type        = string
  default     = "valkey-certificate-issuer"
}

variable "internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with Valkey Cache Solution"
  type        = string
  default     = "valkey-internal-certificate"
}

variable "ui_internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with Redis Commander"
  type        = string
  default     = "ui-internal-certificate"
}

variable "cloudflare_token" {
  description = "Token for generating Ingress Certificates to be associated with OpenBao Secrets Management Solution"
  type        = string
  nullable    = false
}

variable "cloudflare_email" {
  description = "Email for generating Ingress Certificates to be associated with OpenBao Secrets Management Solution"
  type        = string
  nullable    = false
}

variable "cloudflare_issuer_name" {
  description = "Name of the Cloudflare Issuer to be associated with OpenBao Secrets Management Solution"
  type        = string
  default     = "secrets-cloudflare-issuer"
}

variable "acme_server" {
  description = "URL for the ACME Server to be used, defaults to production URL for LetsEncrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with Redis Commander"
  type        = string
  default     = "valkey-ui-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "memory"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}

# --------------- REPLICATION VARIABLES --------------- #
variable "access_namespaces" {
  description = "Namespaces which require access to Valkey through certificates and network"
  type        = string
  nullable    = false
}

# --------------- VALKEY CLUSTER VARIABLES --------------- #
variable "repository" {
  description = "Repository to be used for deployment of Valkey"
  type        = string
  default     = "docker.io/valkey"
}

variable "image" {
  description = "Docker image to be used for deployment of Valkey"
  type        = string
  default     = "valkey"
}

variable "tag" {
  description = "Docker tag to be used for deployment of Valkey"
  type        = string
  default     = "9.0"
}

variable "replicas" {
  description = "Number of replicas to run for Valkey Cluster"
  type        = number
  default     = 3
}

# --------------- VALKEY METRICS VARIABLES --------------- #
variable "metrics_repository" {
  description = "Repository to be used for deployment of Valkey Metrics"
  type        = string
  default     = "docker.io/oliver006"
}

variable "metrics_image" {
  description = "Docker image to be used for deployment of Valkey Metrics"
  type        = string
  default     = "redis_exporter"
}

variable "metrics_tag" {
  description = "Docker tag to be used for deployment of Valkey Metrics"
  type        = string
  default     = "v1.81.0-alpine"
}

# --------------- REDIS COMMMANDER VARIABLES --------------- #
variable "ui_repository" {
  description = "Repository to be used for deployment of Redis Commander"
  type        = string
  default     = "ghcr.io/joeferner"
}

variable "ui_image" {
  description = "Docker image to be used for deployment of Redis Commander"
  type        = string
  default     = "redis-commander"
}

variable "ui_tag" {
  description = "Docker tag to be used for deployment of Redis Commander"
  type        = string
  default     = "0.9.1"
}

variable "proxy_repository" {
  description = "Repository to be used for deployment of Garage NGINX Proxy for TLS"
  type        = string
  default     = "docker.io/library"
}

variable "proxy_image" {
  description = "Docker image to be used for deployment of Garage NGINX Proxy for TLS"
  type        = string
  default     = "nginx"
}

variable "proxy_tag" {
  description = "Docker tag to be used for deployment of Garage NGINX Proxy for TLS"
  type        = string
  default     = "1.29.0"
}
