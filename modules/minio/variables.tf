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

