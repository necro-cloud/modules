# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying OpenBao Secrets Management Solution"
  type        = string
  default     = "openbao"
}

variable "organization_name" {
  description = "Organization name for deploying OpenBao Secrets Management Solution"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying OpenBao Secrets Management Solution"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying OpenBao Secrets Management Solution"
  type        = string
  default     = "openbao"
}

variable "observability_namespace" {
  description = "Namespace where all components for observability are deployed"
  type        = string
  nullable    = false
}

variable "access_namespaces" {
  description = "Namespaces requiring accesses to the OpenBao Cluster in a comma seperated list"
  type = string
  nullable = false
}

# -------------- OPENBAO DEPLOYMENT VARIABLES -------------- #
variable "openbao_configuration" {
  description = "Dictionary filled with OpenBao Configuration Details"
  type        = map(string)
  default = {
    "name"             = "openbao"
    "repository"       = "https://openbao.github.io/openbao-helm"
    "chart"            = "openbao"
    "version"          = "0.25.6"
  }
}

variable "cluster_size" {
  description = "Number of pods to be deployed for High Availability for OpenBao Secrets Management Solution"
  type = number
  default = 3
}

# --------------- CERTIFICATE VARIABLES --------------- #
variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = false
}

variable "certificate_authority_name" {
  description = "Name of the Certificate Authority to be associated with OpenBao Secrets Management Solution"
  type        = string
  default     = "secrets-certificate-authority"
}

variable "issuer_name" {
  description = "Name of the Issuer to be associated with OpenBao Secrets Management Solution"
  type        = string
  default     = "secrets-certificate-issuer"
}

variable "internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with OpenBao Secrets Management Solution"
  type        = string
  default     = "secrets-internal-certificate"
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
  description = "Name of the Ingress Certificate to be associated with OpenBao Secrets Management Solution"
  type        = string
  default     = "secrets-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "secrets"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}

# --------------- OPENBAO CONFIGURATION VARIABLES --------------- #
variable "configurator_repository" {
  description = "Repository to be used for deployment of OpenBao Configurator"
  type        = string
  default     = "quay.io/openbao"
}

variable "configurator_image" {
  description = "Docker image to be used for deployment of OpenBao Configurator"
  type        = string
  default     = "openbao"
}

variable "configurator_tag" {
  description = "Docker tag to be used for deployment of OpenBao Configurator"
  type        = string
  default     = "2.5.1"
}

# --------------- NETWORK POLICY VARIABLES --------------- #
variable "kubernetes_api_ip" {
  description = "IP Address for the Kubernetes API"
  type        = string
  nullable    = false
}

variable "kubernetes_api_protocol" {
  description = "Protocol for the Kubernetes API"
  type        = string
  nullable    = false
}

variable "kubernetes_api_port" {
  description = "Port for the Kubernetes API"
  type        = number
  nullable    = false
}
