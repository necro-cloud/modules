# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying the Observability Stack"
  type        = string
  default     = "ferret"
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
