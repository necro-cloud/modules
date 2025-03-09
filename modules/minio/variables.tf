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

