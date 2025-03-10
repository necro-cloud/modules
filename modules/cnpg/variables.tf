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

