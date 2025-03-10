# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying PostgreSQL Database"
  type        = string
  default     = "postgres"
}

variable "organization_name" {
  description = "Organization name for deploying PostgreSQL Database"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying PostgreSQL Database"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying PostgreSQL Database"
  type        = string
  default     = "postgres"
}

variable "minio_namespace" {
  description = "Namespace for the MinIO Deployment for storing PITR Backups"
  type        = string
  nullable    = false
}

# --------------- CERTIFICATE VARIABLES --------------- #
variable "minio_certificate_authority" {
  description = "Name of the Certificate Authority associated with the MinIO Storage Solution"
  type        = string
  nullable    = false
}

variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = false
}

variable "server_certificate_authority_name" {
  description = "Name of the Certificate Authority to be used with PostgreSQL Server"
  type        = string
  default     = "postgresql-server-certificate-authority"
}

variable "server_issuer_name" {
  description = "Name of the Issuer to be used with PostgreSQL Server"
  type        = string
  default     = "postgresql-server-issuer"
}

variable "server_certificate_name" {
  description = "Name of the Certificate to be used with PostgreSQL Server"
  type        = string
  default     = "postgresql-server-certificate"
}

variable "client_certificate_authority_name" {
  description = "Name of the Certificate Authority to be used with PostgreSQL Client"
  type        = string
  default     = "postgresql-client-certificate-authority"
}

variable "client_issuer_name" {
  description = "Name of the Issuer to be used with PostgreSQL Client"
  type        = string
  default     = "postgresql-client-issuer"
}

variable "client_streaming_replica_certificate_name" {
  description = "Name of the Certificate to be used with PostgreSQL Streaming Replica Client"
  type        = string
  default     = "postgresql-streaming-replica-client-certificate"
}

