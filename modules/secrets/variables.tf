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
