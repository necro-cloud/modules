# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak"
}

variable "organization_name" {
  description = "Organization name for deploying Keycloak Identity Platform solution"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying Keycloak Identity Platform solution"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak"
}

variable "postgres_namespace" {
  description = "Namespace for the PostgreSQL Deployment for database connections"
  type        = string
  nullable    = false
}

# --------------- DATABASE CERTIFICATE VARIABLES --------------- #
variable "database_server_certificate_authority_name" {
  description = "Server Certificate Authority being used for the database"
  type        = string
  nullable    = false
}

variable "database_client_certificate_name" {
  description = "Client Certificate to be used for Keycloak User"
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
  description = "Name of the Certificate Authority to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-certificate-authority"
}

variable "issuer_name" {
  description = "Name of the Issuer to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-certificate-issuer"
}

variable "internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-internal-certificate"
}

variable "cloudflare_token" {
  description = "Token for generating Ingress Certificates to be associated with Keycloak Identity Platform solution"
  type        = string
  nullable    = false
}

variable "cloudflare_email" {
  description = "Email for generating Ingress Certificates to be associated with Keycloak Identity Platform solution"
  type        = string
  nullable    = false
}

variable "cloudflare_issuer_name" {
  description = "Name of the Cloudflare Issuer to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-cloudflare-issuer"
}

variable "acme_server" {
  description = "URL for the ACME Server to be used, defaults to production URL for LetsEncrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "auth"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}

