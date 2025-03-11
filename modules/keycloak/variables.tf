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
