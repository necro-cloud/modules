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

