# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying Garage Storage Solution"
  type        = string
  default     = "garage"
}

variable "organization_name" {
  description = "Organization name for deploying Garage Storage Solution"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying Garage Storage Solution"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying Garage Storage Solution"
  type        = string
  default     = "garage"
}

# --------------- GARAGE CERTIFICATE VARIABLES --------------- #
variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = false
}

variable "certificate_authority_name" {
  description = "Name of the Certificate Authority to be associated with Garage Storage Solution"
  type        = string
  default     = "garage-certificate-authority"
}

variable "issuer_name" {
  description = "Name of the Issuer to be associated with Garage Storage Solution"
  type        = string
  default     = "garage-certificate-issuer"
}

variable "internal_certificate_name" {
  description = "Name of the Internal Certificate to be associated with Garage Storage Solution"
  type        = string
  default     = "garage-internal-certificate"
}

variable "cloudflare_token" {
  description = "Token for generating Ingress Certificates to be associated with Garage Storage Solution"
  type        = string
  nullable    = false
}

variable "cloudflare_email" {
  description = "Email for generating Ingress Certificates to be associated with Garage Storage Solution"
  type        = string
  nullable    = false
}

variable "cloudflare_issuer_name" {
  description = "Name of the Cloudflare Issuer to be associated with Garage Storage Solution"
  type        = string
  default     = "garage-cloudflare-issuer"
}

variable "acme_server" {
  description = "URL for the ACME Server to be used, defaults to production URL for LetsEncrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "api_ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with Garage API"
  type        = string
  default     = "garage-api-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "storage"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
  nullable    = false
}

# --------------- GARAGE CLUSTER VARIABLES --------------- #
variable "garage_cluster_name" {
  description = "Name of the Garage Cluster"
  type        = string
  default     = "garage"
}

variable "cluster_nodes" {
  description = "Number of nodes to deploy Garage Cluster with"
  type        = number
  default     = 3
}

variable "required_storage" {
  description = "Size of the disks to configure Garage Storage with"
  type        = number
  default     = 5
}

variable "repository" {
  description = "Repository to be used for deployment of Garage Storage Solution"
  type        = string
  default     = "dxflrs"
}

variable "image" {
  description = "Docker image to be used for deployment of Garage Storage Solution"
  type        = string
  default     = "amd64_garage"
}

variable "tag" {
  description = "Docker tag to be used for deployment of Garage Storage Solution"
  type        = string
  default     = "v2.0.0"
}

variable "proxy_repository" {
  description = "Repository to be used for deployment of Garage NGINX Proxy for TLS"
  type        = string
  default     = "docker.io/library"
}

variable "proxy_image" {
  description = "Docker image to be used for deployment of Garage NGINX Proxy for TLS"
  type        = string
  default     = "nginx"
}

variable "proxy_tag" {
  description = "Docker tag to be used for deployment of Garage NGINX Proxy for TLS"
  type        = string
  default     = "1.29.0"
}

# --------------- REPLICATION VARIABLES --------------- #
variable "replication_namespaces" {
  description = "Namespaces to which Certificate Authority can be replicated to"
  type        = string
  default     = "postgres"
}

# --------------- GARAGE CONFIGURATION VARIABLES --------------- #
variable "configurator_repository" {
  description = "Repository to be used for deployment of Garage Configurator"
  type        = string
  default     = "quay.io/necronizerslab"
}

variable "configurator_image" {
  description = "Docker image to be used for deployment of Garage Configurator"
  type        = string
  default     = "garage-configurator"
}

variable "configurator_tag" {
  description = "Docker tag to be used for deployment of Garage Configurator"
  type        = string
  default     = "0.7.9"
}

variable "garage_region" {
  description = "Region to be used for the Garage Storage"
  type        = string
  default     = "garage"
}

variable "garage_node_tags" {
  description = "Node Tags to use to configure Garage nodes with"
  type        = list(string)
  default     = ["garage", "node"]
}

variable "required_buckets" {
  description = "Buckets to deploy in the Garage Cluster"
  type        = list(string)
  nullable    = false
}

variable "required_access_keys" {
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
}
