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

# --------------- DATABASE CERTIFICATE VARIABLES --------------- #
variable "database_server_certificate_authority_name" {
  description = "Server Certificate Authority being used for the database"
  type        = string
  nullable    = false
}

variable "database_client_certificate_name" {
  description = "Client Certificate to be used for Keycloak User"
  type        = string
  nullable    = false
}

# --------------- CERTIFICATE VARIABLES --------------- #
variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = false
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
      name  = "KC_HTTPS_CERTIFICATE_FILE"
      value = "/mnt/certs/tls/tls.crt"
    },
    {
      name  = "KC_HTTPS_CERTIFICATE_KEY_FILE"
      value = "/mnt/certs/tls/tls.key"
    },
    {
      name  = "KC_DB_URL"
      value = "jdbc:postgresql://postgresql-cluster-rw.postgres.svc/keycloak?ssl=true&sslmode=verify-full&sslrootcert=/mnt/certs/database/certificate-authority/ca.crt&sslcert=/mnt/certs/database/certificate/tls.crt&sslkey=/mnt/certs/database/certificate/key.der"
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
