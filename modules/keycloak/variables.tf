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

variable "postgres_namespace" {
  description = "Namespace for the PostgreSQL Deployment for database connections"
  type        = string
  nullable    = false
}

variable "observability_namespace" {
  description = "Namespace where all components for observability are deployed"
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.enable_observability ? var.observability_namespace == null ? false : true : true
    error_message = "If Observability is enabled, observability namespace is a required variable to be passed"
  }
}

# --------------- CLUSTER SECRET STORE VARIABLES --------------- #
variable "cluster_secret_store_name" {
  description = "Name of the cluster secret store to be used for pulling and pushing secrets to OpenBao"
  type        = string
  nullable    = false
}

# --------------- DATABASE VARIABLES --------------- #
variable "cluster_name" {
  description = "Database Cluster Name to allow Network Connections to"
  type        = string
  nullable    = false
}

variable "database_certificates_required" {
  description = "Boolean value to control if database certificates are required for authentication or not"
  type        = bool
  nullable    = true
}

variable "database_server_certificate_authority_name" {
  description = "Server Certificate Authority being used for the database"
  type        = string
  nullable    = true
  default     = null
}

variable "database_client_certificate_name" {
  description = "Client Certificate to be used for Keycloak User"
  type        = string
  nullable    = true
  default     = null
}

# --------------- CERTIFICATE VARIABLES --------------- #
variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.enable_internal_tls_certificates ? var.cluster_issuer_name == null ? false : true : true
    error_message = "If Internal TLS Certificates is enabled, cluster issuer name is a required variable to be passed"
  }
}

variable "certificate_authority_name" {
  description = "Name of the Certificate Authority to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-certificate-authority"
}

variable "issuer_name" {
  description = "Name of the Issuer to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-certificate-issuer"
}

variable "internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-internal-certificate"
}

variable "cloudflare_token" {
  description = "Token for generating Ingress Certificates to be associated with Keycloak Identity Platform solution"
  type        = string
  nullable    = false
}

variable "cloudflare_email" {
  description = "Email for generating Ingress Certificates to be associated with Keycloak Identity Platform solution"
  type        = string
  nullable    = false
}

variable "cloudflare_issuer_name" {
  description = "Name of the Cloudflare Issuer to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-cloudflare-issuer"
}

variable "acme_server" {
  description = "URL for the ACME Server to be used, defaults to production URL for LetsEncrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with Keycloak Identity Platform solution"
  type        = string
  default     = "keycloak-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "auth"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}

# --------------- SECRET VARIABLES --------------- #
variable "database_credentials" {
  description = "Name of the secret which contains the database credentials for Keycloak"
  type        = string
  nullable    = false
}

variable "keycloak_credentials" {
  description = "Name of the secret which contains the credentials for the Keycloak Cluster"
  type        = string
  default     = "default-credentials"
}

variable "realm_settings" {
  description = "Realm Settings for pre-installing a realm with Keycloak"
  type = object({
    display_name               = string
    application_name           = string
    base_url                   = string
    valid_login_redirect_path  = string
    valid_logout_redirect_path = string
    smtp_host                  = string
    smtp_port                  = number
    smtp_mail                  = string
    smtp_username              = string
    smtp_password              = string
  })
  nullable  = false
  sensitive = true
}

# --------------- CLUSTER VARIABLES --------------- #
variable "cluster_size" {
  description = "Number of pods to deploy for the Garage Cluster"
  type        = string
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large"], var.cluster_size)
    error_message = "Valid values for variable size are small, medium and large"
  }
}

variable "repository" {
  description = "Repository to be used for deployment of Keycloak"
  type        = string
  default     = "quay.io/keycloak"
}

variable "image" {
  description = "Docker image to be used for deployment of Keycloak"
  type        = string
  default     = "keycloak"
}

variable "tag" {
  description = "Docker tag to be used for deployment of Keycloak"
  type        = string
  default     = "26.4.5"
}

variable "keycloak_environment_variables" {
  default = [
    {
      name  = "KC_HTTP_PORT"
      value = "8080"
    },
    {
      name  = "KC_HTTPS_PORT"
      value = "8443"
    },
    {
      name  = "KC_DB_POOL_INITIAL_SIZE"
      value = "1"
    },
    {
      name  = "KC_DB_POOL_MIN_SIZE"
      value = "1"
    },
    {
      name  = "KC_DB_POOL_MAX_SIZE"
      value = "3"
    },
    {
      name  = "KC_HEALTH_ENABLED"
      value = "true"
    },
    {
      name  = "KC_CACHE"
      value = "ispn"
    },
    {
      name  = "KC_CACHE_STACK"
      value = "jdbc-ping"
    },
    {
      name  = "KC_PROXY"
      value = "passthrough"
    },
    {
      name  = "KC_TRUSTSTORE_PATHS"
      value = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
    }
  ]

  description = "Environment variables for Keycloak Configuration"
}

variable "keycloak_ports" {
  default = [

    {
      name          = "https"
      containerPort = "8443"
      protocol      = "TCP"
    },
    {
      name          = "http"
      containerPort = "8080"
      protocol      = "TCP"
    },
    {
      name          = "management"
      containerPort = "9000"
      protocol      = "TCP"
    },
    {
      name          = "discovery"
      containerPort = "7800"
      protocol      = "TCP"
    },
  ]

  description = "Keycloak Ports Configuration"
}

# --------------- DEPLOYMENT CUSTOMIZATION VARIABLES --------------- #
variable "enable_internal_tls_certificates" {
  description = "Enable or disable deployment of Internal TLS Certificates for the Keycloak Cluster"
  type        = bool
  default     = true
}

variable "enable_observability" {
  description = "Enable or disable observability reporting for the Keycloak Cluster"
  type        = bool
  default     = true
}
