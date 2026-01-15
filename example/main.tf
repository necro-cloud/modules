# Fetch the Kubernetes API Endpoint to be used for whitelisting by other modules
data "kubernetes_endpoints_v1" "kubernetes_api_endpoint" {
  metadata {
    name      = "kubernetes"
    namespace = "default"

  }
}

# Deploy all required helm charts for deploying the infrastructure
module "helm" {
  source               = "git::https://github.com/necro-cloud/modules//modules/helm?ref=main"
  server_node_selector = "cloud"
}

# Setup a Cluster Issuer for all private TLS certificates
module "cluster-issuer" {
  source = "git::https://github.com/necro-cloud/modules//modules/cluster-issuer?ref=main"

  depends_on = [module.helm]
}

# Garage Deployment for an S3 compatible object storage solution
module "garage" {
  source = "git::https://github.com/necro-cloud/modules//modules/garage?ref=main"

  // Certificates Details
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Granting required namespaces access to the Garage cluster
  access_namespaces = "postgres,ferret"

  // Configuring required configurations on the Garage Cluster
  required_buckets     = var.garage_required_buckets
  required_access_keys = var.garage_required_access_keys

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))
}

# Cloudnative PG Deployment for PostgreSQL Database Solution
module "cnpg" {
  source = "git::https://github.com/necro-cloud/modules//modules/cnpg?ref=main"

  // Garage Cluster Details for configuration of PITR Backups
  garage_certificate_authority = module.garage.garage_internal_certificate_secret
  garage_namespace             = module.garage.garage_namespace
  garage_configuration         = "walbackups-credentials"
  backup_bucket_name           = "postgresql"

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

  // Dependency on Garage Deployment  
  depends_on = [module.garage]
}

# FerretDB Deployment for MongoDB Database Solution
module "ferretdb" {
  source = "git::https://github.com/necro-cloud/modules//modules/ferretdb?ref=task/68/authn-setup"

  // Garage Cluster Details for configuration of PITR Backups
  garage_certificate_authority = module.garage.garage_internal_certificate_secret
  garage_namespace             = module.garage.garage_namespace
  garage_configuration         = "walbackups-credentials"
  backup_bucket_name           = "ferret"

  // Required client details to allow access and generate credentials and certificates for
  clients = [
    {
      namespace          = "cloud"
      user               = "cloud"
    }
  ]

  // Certificate details for internal certificates
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Dependency on Garage Deployment  
  depends_on = [module.garage]
}

# Keycloak Cluster Deployment for Identity Solution
module "keycloak" {
  source = "git::https://github.com/necro-cloud/modules//modules/keycloak?ref=main"

  // PostgreSQL Database Details for database details
  cluster_issuer_name                        = module.cluster-issuer.cluster-issuer-name
  postgres_namespace                         = module.cnpg.namespace
  cluster_name                               = module.cnpg.cluster_name
  database_server_certificate_authority_name = module.cnpg.server-certificate-authority
  database_client_certificate_name           = "postgresql-keycloak-client-certificate"
  database_credentials                       = "credentials-keycloak"

  // Certificate details for ingress
  cloudflare_token = var.cloudflare_token
  cloudflare_email = var.cloudflare_email
  domain           = var.domain

  // Realm Settings for auto configuration of required clients
  realm_settings = local.keycloak_realm_settings

  // Dependency on CNPG PostgreSQL Deployment
  depends_on = [module.cnpg]
}

# Valkey Deployment for In Memory Storage Solution
module "valkey" {
  source = "git::https://github.com/necro-cloud/modules//modules/valkey?ref=main"

  // Certificate details for TLS Authentication
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name

  // Granting required namespaces access to the Valkey
  access_namespaces = "cloud"
}
