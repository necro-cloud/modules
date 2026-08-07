# Fetch the Kubernetes API Endpoint to be used for whitelisting by other modules
data "kubernetes_endpoints_v1" "kubernetes_api_endpoint" {
  metadata {
    name      = "kubernetes"
    namespace = "default"

  }
}

# Deploy all required helm charts for deploying the infrastructure
module "helm" {
  source               = "../modules/helm"
  server_node_selector = "cloud"
}

# Setup a Cluster Issuer for all private TLS certificates
module "cluster-issuer" {
  source = "../modules/cluster-issuer"

  depends_on = [module.helm]
}

# Complete Observability Stack Deployment
module "observability" {
  source = "../modules/observability"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Certificates Details
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  depends_on = [module.cluster-issuer]
}

# OpenBao Secrets Management Solution deployment
module "openbao" {
  source = "../modules/openbao"

  // Certificates Details
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Observability details
  observability_namespace = module.observability.observability_namespace

  // Granting required namespaces access to the OpenBao cluster
  access_namespaces = "external-secrets,cloud"

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  depends_on = [module.cluster-issuer]
}

# Garage Deployment for an S3 compatible object storage solution
module "garage" {
  source = "../modules/garage"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

  // Certificates Details
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Granting required namespaces access to the Garage cluster
  access_namespaces = "postgres,ferret"

  // Observability details
  observability_namespace = module.observability.observability_namespace

  // Configuring required configurations on the Garage Cluster
  required_buckets     = var.garage_required_buckets
  required_access_keys = var.garage_required_access_keys

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Enabling and disabling features
  enable_internal_tls_certificates = true
  enable_ui                        = true
  enable_observability             = true

  depends_on = [module.observability, module.openbao]
}

# Cloudnative PG Deployment for PostgreSQL Database Solution
module "cnpg" {
  source = "../modules/cnpg"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

  // Garage Cluster Details for configuration of PITR Backups
  garage_certificate_authority = module.garage.garage_internal_certificate_secret
  garage_namespace             = module.garage.garage_namespace
  garage_configuration         = "walbackups"
  backup_bucket_name           = "postgresql"

  // Observability details
  observability_namespace = module.observability.observability_namespace

  // Required client details to allow access and generate credentials and certificates for
  clients = [
    {
      namespace          = "cloud"
      user               = "cloud"
      database           = "cloud"
      derRequired        = false
      privateKeyEncoding = "PKCS1"
    }
  ]

  // Certificate details for internal and ingress(pgadmin) certificates
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Enabling and disabling features
  enable_internal_tls_certificates = true
  enable_ui                        = true
  enable_pitr_backups              = true
  enable_observability             = true

  // Dependency on Garage Deployment  
  depends_on = [module.garage, module.observability, module.openbao]
}

# FerretDB Deployment for MongoDB Database Solution
module "ferretdb" {
  source = "../modules/ferretdb"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Garage Cluster Details for configuration of PITR Backups
  garage_certificate_authority = module.garage.garage_internal_certificate_secret
  garage_namespace             = module.garage.garage_namespace
  garage_configuration         = "walbackups"
  backup_bucket_name           = "ferret"

  // Observability details
  observability_namespace = module.observability.observability_namespace

  // Cluster sizing details
  cluster_size = "small"

  // Required client details to allow access and generate credentials and certificates for
  clients = [
    {
      namespace = "cloud"
      user      = "cloud"
    }
  ]

  // Certificate details for internal and ingress certificates
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Enabling and disabling features
  enable_internal_tls_certificates = true
  enable_ui                        = true
  enable_pitr_backups              = true
  enable_observability             = true

  // Dependency on Garage Deployment  
  depends_on = [module.garage, module.observability, module.openbao]
}

# Keycloak Cluster Deployment for Identity Solution
module "keycloak" {
  source = "../modules/keycloak"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // PostgreSQL Database Details for database details
  cluster_issuer_name                        = module.cluster-issuer.cluster-issuer-name
  postgres_namespace                         = module.cnpg.namespace
  cluster_name                               = module.cnpg.cluster_name
  database_certificates_required             = true
  database_server_certificate_authority_name = module.cnpg.server-certificate-authority
  database_client_certificate_name           = "postgresql-keycloak-client-certificate"
  database_credentials                       = "credentials-keycloak"

  // Certificate details for ingress
  cloudflare_token = var.cloudflare_token
  cloudflare_email = var.cloudflare_email
  domain           = var.domain

  // Observability details
  observability_namespace = module.observability.observability_namespace

  // Realm Settings for auto configuration of required clients
  realm_settings = local.keycloak_realm_settings

  // Dependency on CNPG PostgreSQL Deployment
  depends_on = [module.cnpg, module.observability, module.openbao]
}

# Valkey Deployment for In Memory Storage Solution
module "valkey" {
  source = "../modules/valkey"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Certificates Details
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Granting required namespaces access to the Valkey
  access_namespaces = "cloud"

  // Observability details
  observability_namespace = module.observability.observability_namespace

  depends_on = [module.observability, module.openbao]
}
