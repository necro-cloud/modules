## [OPTIONAL MODULE] necronizer's cloud keycloak module

OpenTofu Module to deploy [Keycloak](https://www.keycloak.org/) Identity Management on the Kubernetes Cluster

Required Modules to deploy Keycloak Identity Management:
1. [Cluster Issuer](../cluster-issuer) (Optional if setting `enable_internal_tls_certificates` as `false`)
2. [Cloudnative PG](../cnpg)
3. [Observability](../observability) (Optional if setting `enable_observability` as `false`)
4. [OpenBao](../openbao)

## Table of Contents
- [Providers](#providers)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.realm_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_ingress_v1.ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.database_client_certificate_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.database_credentials_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.database_server_certificate_authority_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.keycloak_credentials_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.middleware_buffering](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.middleware_rewrite](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.password_generator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.public_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_keycloak_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_realm_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.realm_secrets_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.transport](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.keycloak_network_access_policy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_pod_disruption_budget_v1.keycloak_pdb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_secret.cloudflare_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.keycloak_discovery](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.keycloak_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_stateful_set.keycloak_cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acme_server"></a> [acme\_server](#input\_acme\_server) | URL for the ACME Server to be used, defaults to production URL for LetsEncrypt | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying Keycloak Identity Platform solution | `string` | `"keycloak"` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-certificate-authority"` | no |
| <a name="input_cloudflare_email"></a> [cloudflare\_email](#input\_cloudflare\_email) | Email for generating Ingress Certificates to be associated with Keycloak Identity Platform solution | `string` | n/a | yes |
| <a name="input_cloudflare_issuer_name"></a> [cloudflare\_issuer\_name](#input\_cloudflare\_issuer\_name) | Name of the Cloudflare Issuer to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-cloudflare-issuer"` | no |
| <a name="input_cloudflare_token"></a> [cloudflare\_token](#input\_cloudflare\_token) | Token for generating Ingress Certificates to be associated with Keycloak Identity Platform solution | `string` | n/a | yes |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Database Cluster Name to allow Network Connections to | `string` | n/a | yes |
| <a name="input_cluster_secret_store_name"></a> [cluster\_secret\_store\_name](#input\_cluster\_secret\_store\_name) | Name of the cluster secret store to be used for pulling and pushing secrets to OpenBao | `string` | n/a | yes |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | Number of pods to deploy for the Garage Cluster | `string` | `"small"` | no |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying Keycloak Identity Platform solution | `string` | `"India"` | no |
| <a name="input_database_certificates_required"></a> [database\_certificates\_required](#input\_database\_certificates\_required) | Boolean value to control if database certificates are required for authentication or not | `bool` | n/a | yes |
| <a name="input_database_client_certificate_name"></a> [database\_client\_certificate\_name](#input\_database\_client\_certificate\_name) | Client Certificate to be used for Keycloak User | `string` | `null` | no |
| <a name="input_database_credentials"></a> [database\_credentials](#input\_database\_credentials) | Name of the secret which contains the database credentials for Keycloak | `string` | n/a | yes |
| <a name="input_database_server_certificate_authority_name"></a> [database\_server\_certificate\_authority\_name](#input\_database\_server\_certificate\_authority\_name) | Server Certificate Authority being used for the database | `string` | `null` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for which Ingress Certificate is to be generated for | `string` | n/a | yes |
| <a name="input_enable_internal_tls_certificates"></a> [enable\_internal\_tls\_certificates](#input\_enable\_internal\_tls\_certificates) | Enable or disable deployment of Internal TLS Certificates for the Keycloak Cluster | `bool` | `true` | no |
| <a name="input_enable_observability"></a> [enable\_observability](#input\_enable\_observability) | Enable or disable observability reporting for the Keycloak Cluster | `bool` | `true` | no |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name for which Ingress Certificate is to be generated for | `string` | `"auth"` | no |
| <a name="input_image"></a> [image](#input\_image) | Docker image to be used for deployment of Keycloak | `string` | `"keycloak"` | no |
| <a name="input_ingress_certificate_name"></a> [ingress\_certificate\_name](#input\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-ingress-certificate"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-certificate-issuer"` | no |
| <a name="input_keycloak_credentials"></a> [keycloak\_credentials](#input\_keycloak\_credentials) | Name of the secret which contains the credentials for the Keycloak Cluster | `string` | `"default-credentials"` | no |
| <a name="input_keycloak_environment_variables"></a> [keycloak\_environment\_variables](#input\_keycloak\_environment\_variables) | Environment variables for Keycloak Configuration | `list` | <pre>[<br/>  {<br/>    "name": "KC_HTTP_PORT",<br/>    "value": "8080"<br/>  },<br/>  {<br/>    "name": "KC_HTTPS_PORT",<br/>    "value": "8443"<br/>  },<br/>  {<br/>    "name": "KC_DB_POOL_INITIAL_SIZE",<br/>    "value": "1"<br/>  },<br/>  {<br/>    "name": "KC_DB_POOL_MIN_SIZE",<br/>    "value": "1"<br/>  },<br/>  {<br/>    "name": "KC_DB_POOL_MAX_SIZE",<br/>    "value": "3"<br/>  },<br/>  {<br/>    "name": "KC_HEALTH_ENABLED",<br/>    "value": "true"<br/>  },<br/>  {<br/>    "name": "KC_CACHE",<br/>    "value": "ispn"<br/>  },<br/>  {<br/>    "name": "KC_CACHE_STACK",<br/>    "value": "jdbc-ping"<br/>  },<br/>  {<br/>    "name": "KC_PROXY",<br/>    "value": "passthrough"<br/>  },<br/>  {<br/>    "name": "KC_TRUSTSTORE_PATHS",<br/>    "value": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"<br/>  }<br/>]</pre> | no |
| <a name="input_keycloak_ports"></a> [keycloak\_ports](#input\_keycloak\_ports) | Keycloak Ports Configuration | `list` | <pre>[<br/>  {<br/>    "containerPort": "8443",<br/>    "name": "https",<br/>    "protocol": "TCP"<br/>  },<br/>  {<br/>    "containerPort": "8080",<br/>    "name": "http",<br/>    "protocol": "TCP"<br/>  },<br/>  {<br/>    "containerPort": "9000",<br/>    "name": "management",<br/>    "protocol": "TCP"<br/>  },<br/>  {<br/>    "containerPort": "7800",<br/>    "name": "discovery",<br/>    "protocol": "TCP"<br/>  }<br/>]</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying Keycloak Identity Platform solution | `string` | `"keycloak"` | no |
| <a name="input_observability_namespace"></a> [observability\_namespace](#input\_observability\_namespace) | Namespace where all components for observability are deployed | `string` | `null` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying Keycloak Identity Platform solution | `string` | `"cloud"` | no |
| <a name="input_postgres_namespace"></a> [postgres\_namespace](#input\_postgres\_namespace) | Namespace for the PostgreSQL Deployment for database connections | `string` | n/a | yes |
| <a name="input_realm_settings"></a> [realm\_settings](#input\_realm\_settings) | Realm Settings for pre-installing a realm with Keycloak | <pre>object({<br/>    display_name               = string<br/>    application_name           = string<br/>    base_url                   = string<br/>    valid_login_redirect_path  = string<br/>    valid_logout_redirect_path = string<br/>    smtp_host                  = string<br/>    smtp_port                  = number<br/>    smtp_mail                  = string<br/>    smtp_username              = string<br/>    smtp_password              = string<br/>  })</pre> | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository to be used for deployment of Keycloak | `string` | `"quay.io/keycloak"` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | Docker tag to be used for deployment of Keycloak | `string` | `"26.4.5"` | no |

## Outputs

No outputs.

## Examples

**1. Basic Deployment of the Keycloak Identity Management with internal TLS certificates, observability and database certificates turned off**

```terraform
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

# OpenBao Secrets Management Solution deployment
module "openbao" {
  source = "../modules/openbao"

  // Cluster sizing details
  cluster_size = "small"

  // Granting required namespaces access to the OpenBao cluster
  access_namespaces = "external-secrets,cloud"

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Enabling and disabling features
  enable_internal_tls_certificates = false
  enable_ui                        = false
  enable_observability             = false

  depends_on = [module.helm]
}

# Cloudnative PG Deployment for PostgreSQL Database Solution
module "cnpg" {
  source = "../modules/cnpg"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

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

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Enabling and disabling features
  enable_internal_tls_certificates = false
  enable_ui                        = false
  enable_pitr_backups              = false
  enable_observability             = false

  // Dependency on Garage Deployment  
  depends_on = [ module.helm, module.openbao ]
}

module "keycloak" {
  source = "../modules/keycloak"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

  // PostgreSQL Database Details for database details
  postgres_namespace                         = module.cnpg.namespace
  cluster_name                               = module.cnpg.cluster_name
  database_certificates_required             = false
  database_credentials                       = "credentials-keycloak"

  // Certificate details for ingress
  cloudflare_token = var.cloudflare_token
  cloudflare_email = var.cloudflare_email
  domain           = var.domain

  // Realm Settings for auto configuration of required clients
  realm_settings = local.keycloak_realm_settings

  // Enabling and disabling features
  enable_internal_tls_certificates = false
  enable_observability             = false

  // Dependency on CNPG PostgreSQL Deployment
  depends_on = [module.cnpg, module.openbao]
}
```

**2. Basic Deployment of the Keycloak Identity Management with internal TLS certificates and observability turned off and database certificates turned on**

```terraform
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

  // Enabling and disabling features
  enable_internal_tls_certificates = true

  depends_on = [module.helm, module.cluster-issuer]
}

# OpenBao Secrets Management Solution deployment
module "openbao" {
  source = "../modules/openbao"

  // Certificates Details
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Cluster sizing details
  cluster_size = "small"

  // Observability details
  observability_namespace = module.observability.observability_namespace

  // Granting required namespaces access to the OpenBao cluster
  access_namespaces = "external-secrets,cloud"

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Enabling and disabling features
  enable_internal_tls_certificates = true
  enable_ui                        = true
  enable_observability             = true

  depends_on = [module.helm, module.cluster-issuer]
}

# Cloudnative PG Deployment for PostgreSQL Database Solution
module "cnpg" {
  source = "../modules/cnpg"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

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
  enable_pitr_backups              = false
  enable_observability             = true

  // Dependency on Garage Deployment  
  depends_on = [ module.helm, module.openbao, module.observability, module.cluster-issuer ]
}

# Keycloak Cluster Deployment for Identity Solution
module "keycloak" {
  source = "../modules/keycloak"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

  // PostgreSQL Database Details for database details
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

  // Realm Settings for auto configuration of required clients
  realm_settings = local.keycloak_realm_settings

  // Enabling and disabling features
  enable_internal_tls_certificates = false
  enable_observability             = false

  // Dependency on CNPG PostgreSQL Deployment
  depends_on = [module.cnpg, module.observability, module.openbao]
}
```

**3. Deployment of the Keycloak Identity Management with Observability Enabled**

```terraform
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

  // Enabling and disabling features
  enable_internal_tls_certificates = true

  depends_on = [module.helm, module.cluster-issuer]
}

# OpenBao Secrets Management Solution deployment
module "openbao" {
  source = "../modules/openbao"

  // Certificates Details
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Cluster sizing details
  cluster_size = "small"

  // Observability details
  observability_namespace = module.observability.observability_namespace

  // Granting required namespaces access to the OpenBao cluster
  access_namespaces = "external-secrets,cloud"

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Enabling and disabling features
  enable_internal_tls_certificates = true
  enable_ui                        = true
  enable_observability             = true

  depends_on = [module.helm, module.cluster-issuer]
}

# Cloudnative PG Deployment for PostgreSQL Database Solution
module "cnpg" {
  source = "../modules/cnpg"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

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
  enable_pitr_backups              = false
  enable_observability             = true

  // Dependency on Garage Deployment  
  depends_on = [ module.helm, module.openbao, module.observability, module.cluster-issuer ]
}

# Keycloak Cluster Deployment for Identity Solution
module "keycloak" {
  source = "../modules/keycloak"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

  // PostgreSQL Database Details for database details
  # cluster_issuer_name                        = module.cluster-issuer.cluster-issuer-name
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

  // Enabling and disabling features
  enable_internal_tls_certificates = false
  enable_observability             = true

  // Dependency on CNPG PostgreSQL Deployment
  depends_on = [module.cnpg, module.observability, module.openbao]
}
```

**4. Deployment of the Keycloak Identity Management with Internal TLS Certificates Enabled**

```terraform
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

  // Enabling and disabling features
  enable_internal_tls_certificates = true

  depends_on = [module.helm, module.cluster-issuer]
}

# OpenBao Secrets Management Solution deployment
module "openbao" {
  source = "../modules/openbao"

  // Certificates Details
  cluster_issuer_name = module.cluster-issuer.cluster-issuer-name
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Cluster sizing details
  cluster_size = "small"

  // Observability details
  observability_namespace = module.observability.observability_namespace

  // Granting required namespaces access to the OpenBao cluster
  access_namespaces = "external-secrets,cloud"

  // Whitelisting Kubernetes API Endpoints in the Network Policy
  kubernetes_api_ip       = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].address[*].ip))
  kubernetes_api_protocol = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].protocol))
  kubernetes_api_port     = one(flatten(data.kubernetes_endpoints_v1.kubernetes_api_endpoint.subset[*].port[*].port))

  // Enabling and disabling features
  enable_internal_tls_certificates = true
  enable_ui                        = true
  enable_observability             = true

  depends_on = [module.helm, module.cluster-issuer]
}

# Cloudnative PG Deployment for PostgreSQL Database Solution
module "cnpg" {
  source = "../modules/cnpg"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

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
  enable_pitr_backups              = false
  enable_observability             = true

  // Dependency on Garage Deployment  
  depends_on = [ module.helm, module.openbao, module.observability, module.cluster-issuer ]
}

# Keycloak Cluster Deployment for Identity Solution
module "keycloak" {
  source = "../modules/keycloak"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

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

  // Enabling and disabling features
  enable_internal_tls_certificates = true
  enable_observability             = true

  // Dependency on CNPG PostgreSQL Deployment
  depends_on = [module.cnpg, module.observability, module.openbao]
}
```

