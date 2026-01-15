# --------------- GENERAL VARIABLES --------------- #
variable "app_name" {
  description = "App name for deploying Ferret Database"
  type        = string
  default     = "ferret"
}

variable "organization_name" {
  description = "Organization name for deploying Ferret Database"
  type        = string
  default     = "cloud"
}

variable "country_name" {
  description = "Country name for deploying Ferret Database"
  type        = string
  default     = "India"
}

# --------------- NAMESPACE VARIABLES --------------- #
variable "namespace" {
  description = "Namespace to be used for deploying Ferret Database"
  type        = string
  default     = "ferret"
}

variable "garage_namespace" {
  description = "Namespace for the Garage Deployment for storing PITR Backups"
  type        = string
  nullable    = false
}

# --------------- CERTIFICATE VARIABLES --------------- #
variable "garage_certificate_authority" {
  description = "Name of the Certificate Authority associated with the Garage Storage Solution"
  type        = string
  nullable    = false
}

variable "cluster_issuer_name" {
  description = "Name for the Cluster Issuer to be used to generate internal self signed certificates"
  type        = string
  nullable    = false
}

variable "server_certificate_authority_name" {
  description = "Name of the Certificate Authority to be used with Ferret Server"
  type        = string
  default     = "ferretdb-server-certificate-authority"
}

variable "server_issuer_name" {
  description = "Name of the Issuer to be used with Ferret Server"
  type        = string
  default     = "ferretdb-server-issuer"
}

variable "server_certificate_name" {
  description = "Name of the Certificate to be used with Ferret Server"
  type        = string
  default     = "ferretdb-server-certificate"
}

variable "client_certificate_authority_name" {
  description = "Name of the Certificate Authority to be used with Ferret Client"
  type        = string
  default     = "ferretdb-client-certificate-authority"
}

variable "client_issuer_name" {
  description = "Name of the Issuer to be used with Ferret Client"
  type        = string
  default     = "ferretdb-client-issuer"
}

variable "client_streaming_replica_certificate_name" {
  description = "Name of the Certificate to be used with Ferret Streaming Replica Client"
  type        = string
  default     = "ferretdb-streaming-replica-client-certificate"
}

variable "cloudflare_token" {
  description = "Token for generating Ingress Certificates to be associated with MongoExpress"
  type        = string
  nullable    = false
}

variable "cloudflare_email" {
  description = "Email for generating Ingress Certificates to be associated with MongoExpress"
  type        = string
  nullable    = false
}

variable "cloudflare_issuer_name" {
  description = "Name of the Cloudflare Issuer to be associated with MongoExpress"
  type        = string
  default     = "mongo-express-cloudflare-issuer"
}

variable "acme_server" {
  description = "URL for the ACME Server to be used, defaults to production URL for LetsEncrypt"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "ingress_certificate_name" {
  description = "Name of the Ingress Certificate to be associated with MongoExpress"
  type        = string
  default     = "mongo-express-ingress-certificate"
}

variable "host_name" {
  description = "Host name for which Ingress Certificate is to be generated for"
  type        = string
  default     = "nosql"
}

variable "domain" {
  description = "Domain for which Ingress Certificate is to be generated for"
  type        = string
}

# --------------- USER CONFIGURATION VARIABLES --------------- #
variable "clients" {
  description = "Object List of clients who need databases and users to be configured for"
  type = list(object({
    namespace          = string
    user               = string
  }))
  default = []
}

# --------------- CLUSTER VARIABLES VARIABLES --------------- #
variable "garage_configuration" {
  description = "Garage Configuration for storing PITR Backups"
  type        = string
  nullable    = false
}

variable "cluster_name" {
  description = "Name of the Ferret Database Cluster to be created"
  type        = string
  default     = "ferret-postgresql-cluster"
}

variable "cluster_postgresql_version" {
  description = "Version of Ferret Database to use and deploy"
  type        = number
  default     = 17
}

variable "cluster_size" {
  description = "Number of pods to deploy for the Ferret Cluster"
  type        = number
  default     = 2
}

variable "backup_bucket_name" {
  description = "Name of the bucket for storing PITR Backups in Garage"
  type        = string
  nullable    = false
}

# --------------- FERRET DEPLOYMENT VARIABLES --------------- #
variable "repository" {
  description = "Repository to be used for deployment of FerretDB"
  type        = string
  default     = "ghcr.io/ferretdb"
}

variable "image" {
  description = "Docker image to be used for deployment of FerretDB"
  type        = string
  default     = "ferretdb"
}

variable "tag" {
  description = "Docker tag to be used for deployment of FerretDB"
  type        = string
  default     = "2.7.0"
}

variable "mongo_express_repository" {
  description = "Repository to be used for deployment of Mongo Express UI"
  type        = string
  default     = "docker.io/library"
}

variable "mongo_express_image" {
  description = "Docker image to be used for deployment of Mongo Express UI"
  type        = string
  default     = "nginx"
}

variable "mongo_express_tag" {
  description = "Docker tag to be used for deployment of Mongo Express UI"
  type        = string
  default     = "1.0.2-20-alpine3.19"
}

# --------------- NETWORK POLICY VARIABLES --------------- #
variable "kubernetes_api_ip" {
  description = "IP Address for the Kubernetes API"
  type        = string
  nullable    = false
}

variable "kubernetes_api_protocol" {
  description = "Protocol for the Kubernetes API"
  type        = string
  nullable    = false
}

variable "kubernetes_api_port" {
  description = "Port for the Kubernetes API"
  type        = number
  nullable    = false
}
