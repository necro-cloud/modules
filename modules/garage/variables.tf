# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying Garage Storage Solution"
  type        = string
  default     = "garage"
}

variable "organization_name" {
  description = "Organization name for deploying Garage Storage Solution"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying Garage Storage Solution"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying Garage Storage Solution"
  type        = string
  default     = "garage"
}

# --------------- GARAGE CERTIFICATE VARIABLES --------------- #
variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = false
}

variable "certificate_authority_name" {
  description = "Name of the Certificate Authority to be associated with Garage Storage Solution"
  type        = string
  default     = "garage-certificate-authority"
}

variable "issuer_name" {
  description = "Name of the Issuer to be associated with Garage Storage Solution"
  type        = string
  default     = "garage-certificate-issuer"
}

variable "internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with Garage Storage Solution"
  type        = string
  default     = "garage-internal-certificate"
}

variable "cloudflare_token" {
  description = "Token for generating Ingress Certificates to be associated with Garage Storage Solution"
  type        = string
  nullable    = false
}

variable "cloudflare_email" {
  description = "Email for generating Ingress Certificates to be associated with Garage Storage Solution"
  type        = string
  nullable    = false
}

variable "cloudflare_issuer_name" {
  description = "Name of the Cloudflare Issuer to be associated with Garage Storage Solution"
  type        = string
  default     = "garage-cloudflare-issuer"
}

variable "acme_server" {
  description = "URL for the ACME Server to be used, defaults to production URL for LetsEncrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "api_ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with Garage API"
  type        = string
  default     = "garage-api-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "garage"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}

# --------------- REPLICATION VARIABLES --------------- #
variable "replication_namespaces" {
  description = "Namespaces to which Certificate Authority can be replicated to"
  type        = string
  default     = "postgres"
}

# --------------- GARAGE CONFIGURATION VARIABLES --------------- #
variable "configuration_file" {
  description = "Path of the file for Garage Storage Configuration"
  type        = string
  default     = "configuration.json"
}

