# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying MinIO Storage Solution"
  type        = string
  default     = "minio"
}

variable "organization_name" {
  description = "Organization name for deploying MinIO Storage Solution"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying MinIO Storage Solution"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying MinIO Storage Solution"
  type        = string
  default     = "minio"
}

variable "operator_namespace" {
  description = "Namespace where the MinIO Operator is deployed in"
  type        = string
  nullable    = false
}

# --------------- MINIO OPERATOR CERTIFICATE VARIABLES --------------- #
variable "operator_certificate_authority_name" {
  description = "Name of the Certificate Authority to be associated with MinIO Operator"
  type        = string
  default     = "operator-ca-tls"
}

variable "operator_issuer_name" {
  description = "Name of the Issuer to be associated with MinIO Operator"
  type        = string
  default     = "operator-ca-issuer"
}

variable "operator_internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with MinIO Operator"
  type        = string
  default     = "sts-certmanager-cert"
}

# --------------- MINIO CERTIFICATE VARIABLES --------------- #
variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = false
}

variable "certificate_authority_name" {
  description = "Name of the Certificate Authority to be associated with MinIO Storage Solution"
  type        = string
  default     = "minio-certificate-authority"
}

variable "issuer_name" {
  description = "Name of the Issuer to be associated with MinIO Storage Solution"
  type        = string
  default     = "minio-certificate-issuer"
}

variable "internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with MinIO Storage Solution"
  type        = string
  default     = "minio-internal-certificate"
}

variable "cloudflare_token" {
  description = "Token for generating Ingress Certificates to be associated with MinIO Storage Solution"
  type        = string
  nullable    = false
}

variable "cloudflare_email" {
  description = "Email for generating Ingress Certificates to be associated with MinIO Storage Solution"
  type        = string
  nullable    = false
}

variable "cloudflare_issuer_name" {
  description = "Name of the Cloudflare Issuer to be associated with MinIO Storage Solution"
  type        = string
  default     = "minio-cloudflare-issuer"
}

variable "acme_server" {
  description = "URL for the ACME Server to be used, defaults to production URL for LetsEncrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with MinIO Storage Solution"
  type        = string
  default     = "minio-ingress-certificate"
}

variable "api_ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with MinIO API Storage Solution"
  type        = string
  default     = "minio-api-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "storage"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}

# --------------- REPLICATION VARIABLES --------------- #
variable "database_replication_namespaces" {
  description = "Namespaces to which Certificate Authority can be replicated to"
  type        = string
  default     = "postgres"
}

variable "operator_tenant_certificate_name" {
  description = "Name of the Certificate of the Tenant to be used by the MinIO Operator"
  type        = string
  default     = "operator-ca-tls-tenant"
}

# --------------- MINIO TENANT CONFIGURATION VARIABLES --------------- #
variable "storage_configuration_name" {
  description = "Name of the secret for storing MinIO Storage Configuration"
  type        = string
  default     = "storage-configuration"
}

variable "admin_user" {
  description = "Name of the admin user for accessing MinIO Tenant"
  type        = string
  default     = "minio.admin"
}

variable "users" {
  description = "List of users for which MinIO Tenant needs to be deployed with"
  type        = list(string)
  default     = []
}

variable "buckets" {
  description = "List of buckets for which MinIO Tenant needs to be deployed with"
  type        = list(string)
  default     = []
}
