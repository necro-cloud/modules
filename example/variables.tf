# --------------- DNS SETTINGS VARIABLES --------------- #
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

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}

# --------------- GARAGE CONFIGURATION VARIABLES --------------- #

variable "garage_required_access_keys" {
  description = "Access Keys required to be configured within the Garage Cluster"
  type = list(object({
    name         = string
    createBucket = bool
    permissions = list(object({
      bucket = string
      owner  = bool
      read   = bool
      write  = bool
    }))
  }))
  default = [
    {
      name         = "walbackups",
      createBucket = false,
      permissions = [
        {
          bucket = "postgresql",
          owner  = true,
          read   = true,
          write  = true
        },
        {
          bucket = "ferret",
          owner  = true,
          read   = true,
          write  = true
        }
      ]
    },
    {
      name         = "master",
      createBucket = true,
      permissions = [
        {
          bucket = "postgresql",
          owner  = true,
          read   = true,
          write  = true
        },
        {
          bucket = "cloud",
          owner  = true,
          read   = true,
          write  = true
      }]
    },
    {
      name         = "cloud",
      createBucket = true,
      permissions = [
        {
          bucket = "cloud",
          owner  = true,
          read   = true,
          write  = true
        },
      ]
  }]
}

variable "garage_required_buckets" {
  description = "Buckets to deploy in the Garage Cluster"
  type        = list(string)
  default     = ["cloud", "postgresql", "ferret"]
}

# --------------- KEYCLOAK REALM CONFIGURATION VARIABLES --------------- #

variable "keycloak_authentication_base_url" {
  description = "Base URL for Keycloak in order to use SSO Authentication with"
  type        = string
  default     = "http://localhost:5173"
}

variable "keycloak_authentication_valid_login_redirect_path" {
  description = "Valid Login Redirect Path for Keycloak in order to use SSO Authentication with"
  type        = string
  default     = "/auth/signin/callback"
}

variable "keycloak_authentication_valid_logout_redirect_path" {
  description = "Valid Logout Redirect Path for Keycloak in order to use SSO Authentication with"
  type        = string
  default     = "/auth/signout/callback"
}

# --------------- SMTP SERVER VARIABLES --------------- #
variable "smtp_host" {
  description = "Host of the SMTP Server to be used for sending mails"
  type        = string
  nullable    = false
}

variable "smtp_port" {
  description = "Port Number of the SMTP Server to be used for sending mails"
  type        = number
  nullable    = false
}

variable "smtp_mail" {
  description = "Mail ID of the SMTP Server to be used for sending mails"
  type        = string
  nullable    = false
}

variable "smtp_username" {
  description = "Username of the SMTP Server to be used for authentication"
  type        = string
  nullable    = false
}

variable "smtp_password" {
  description = "Password of the SMTP Server to be used for authentication"
  type        = string
  nullable    = false
}
