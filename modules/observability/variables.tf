# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying the Observability Stack"
  type        = string
  default     = "observability"
}

variable "organization_name" {
  description = "Organization name for deploying the Observability Stack"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying the Observability Stack"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying the Observability Stack"
  type        = string
  default     = "observability"
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
  description = "Name of the Certificate Authority to be associated with Observability Platform"
  type        = string
  default     = "observability-certificate-authority"
}

variable "issuer_name" {
  description = "Name of the Issuer to be associated with Observability Platform"
  type        = string
  default     = "observability-certificate-issuer"
}

variable "internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with Observability Platform"
  type        = string
  default     = "observability-internal-certificate"
}

variable "cloudflare_token" {
  description = "Token for generating Ingress Certificates to be associated with Observability Platform"
  type        = string
  nullable    = false
}

variable "cloudflare_email" {
  description = "Email for generating Ingress Certificates to be associated with Observability Platform"
  type        = string
  nullable    = false
}

variable "cloudflare_issuer_name" {
  description = "Name of the Cloudflare Issuer to be associated with Observability Platform"
  type        = string
  default     = "observability-cloudflare-issuer"
}

variable "acme_server" {
  description = "URL for the ACME Server to be used, defaults to production URL for LetsEncrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with Observability Platform"
  type        = string
  default     = "observability-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "observability"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}
