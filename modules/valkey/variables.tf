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

# --------------- REPLICATION VARIABLES --------------- #
variable "replication_namespaces" {
  description = "Namespaces where the certificates"
  type        = string
  nullable    = false
}

