## [OPTIONAL MODULE] necronizer's cloud garage module

OpenTofu Module to deploy [Garage](https://garagehq.deuxfleurs.fr/) Object Storage on the Kubernetes Cluster

Required Modules to deploy Garage Object Storage:
1. [Cluster Issuer](../cluster-issuer) (Optional if setting `enable_internal_tls_certificates` as `false`)
2. [Observability](../observability) (Optional if setting `enable_observability` as `false`)
3. [OpenBao](../openbao)

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
| [kubernetes_cluster_role.garage_crds](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.garage_crds_rolebindings](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.configurator-options](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.garage_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.garage_ui_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.nginx_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.ui_nginx_conf](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_deployment.garage_ui](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.api_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_ingress_v1.ui_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_job.configurator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_manifest.admin_password_generator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.admin_password_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.api_ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.garage_rpc_generator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.garage_rpc_secret_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.middleware_buffering](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.middleware_rewrite](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.public_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_access_keys](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_admin_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_garage_rpc_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_ui_admin_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.transport](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ui_admin_password_generator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ui_admin_password_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ui_ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ui_internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.garage_network_access_policy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_pod_disruption_budget_v1.garage_pdb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_role.garage_configurator_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.garage_configurator_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret.cloudflare_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.garage-headless](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.garage-service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.garage-ui-service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service_account.garage_configurator_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.garage_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_stateful_set.statefulset](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_namespaces"></a> [access\_namespaces](#input\_access\_namespaces) | Namespaces that require internal access to Garage | `string` | `"postgres"` | no |
| <a name="input_acme_server"></a> [acme\_server](#input\_acme\_server) | URL for the ACME Server to be used, defaults to production URL for LetsEncrypt | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_api_ingress_certificate_name"></a> [api\_ingress\_certificate\_name](#input\_api\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with Garage API | `string` | `"garage-api-ingress-certificate"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying Garage Storage Solution | `string` | `"garage"` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with Garage Storage Solution | `string` | `"garage-certificate-authority"` | no |
| <a name="input_cloudflare_email"></a> [cloudflare\_email](#input\_cloudflare\_email) | Email for generating Ingress Certificates to be associated with Garage Storage Solution | `string` | n/a | yes |
| <a name="input_cloudflare_issuer_name"></a> [cloudflare\_issuer\_name](#input\_cloudflare\_issuer\_name) | Name of the Cloudflare Issuer to be associated with Garage Storage Solution | `string` | `"garage-cloudflare-issuer"` | no |
| <a name="input_cloudflare_token"></a> [cloudflare\_token](#input\_cloudflare\_token) | Token for generating Ingress Certificates to be associated with Garage Storage Solution | `string` | n/a | yes |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | `null` | no |
| <a name="input_cluster_secret_store_name"></a> [cluster\_secret\_store\_name](#input\_cluster\_secret\_store\_name) | Name of the cluster secret store to be used for pulling and pushing secrets to OpenBao | `string` | n/a | yes |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | Number of pods to deploy for the Garage Cluster | `string` | `"small"` | no |
| <a name="input_configurator_image"></a> [configurator\_image](#input\_configurator\_image) | Docker image to be used for deployment of Garage Configurator | `string` | `"garage-configurator"` | no |
| <a name="input_configurator_repository"></a> [configurator\_repository](#input\_configurator\_repository) | Repository to be used for deployment of Garage Configurator | `string` | `"quay.io/necronizerslab"` | no |
| <a name="input_configurator_tag"></a> [configurator\_tag](#input\_configurator\_tag) | Docker tag to be used for deployment of Garage Configurator | `string` | `"0.8.10"` | no |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying Garage Storage Solution | `string` | `"India"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for which Ingress Certificate is to be generated for | `string` | n/a | yes |
| <a name="input_enable_internal_tls_certificates"></a> [enable\_internal\_tls\_certificates](#input\_enable\_internal\_tls\_certificates) | Enable or disable deployment of Internal TLS Certificates for the Garage Cluster | `bool` | `true` | no |
| <a name="input_enable_observability"></a> [enable\_observability](#input\_enable\_observability) | Enable or disable observability reporting for the Garage Cluster | `bool` | `true` | no |
| <a name="input_enable_ui"></a> [enable\_ui](#input\_enable\_ui) | Enable or disable deployment of PGAdmin for the Garage Cluster | `bool` | `true` | no |
| <a name="input_garage_cluster_name"></a> [garage\_cluster\_name](#input\_garage\_cluster\_name) | Name of the Garage Cluster | `string` | `"garage"` | no |
| <a name="input_garage_node_tags"></a> [garage\_node\_tags](#input\_garage\_node\_tags) | Node Tags to use to configure Garage nodes with | `list(string)` | <pre>[<br/>  "garage",<br/>  "node"<br/>]</pre> | no |
| <a name="input_garage_region"></a> [garage\_region](#input\_garage\_region) | Region to be used for the Garage Storage | `string` | `"garage"` | no |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name for which Ingress Certificate is to be generated for | `string` | `"storage"` | no |
| <a name="input_image"></a> [image](#input\_image) | Docker image to be used for deployment of Garage Storage Solution | `string` | `"amd64_garage"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with Garage Storage Solution | `string` | `"garage-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with Garage Storage Solution | `string` | `"garage-certificate-issuer"` | no |
| <a name="input_kubernetes_api_ip"></a> [kubernetes\_api\_ip](#input\_kubernetes\_api\_ip) | IP Address for the Kubernetes API | `string` | n/a | yes |
| <a name="input_kubernetes_api_port"></a> [kubernetes\_api\_port](#input\_kubernetes\_api\_port) | Port for the Kubernetes API | `number` | n/a | yes |
| <a name="input_kubernetes_api_protocol"></a> [kubernetes\_api\_protocol](#input\_kubernetes\_api\_protocol) | Protocol for the Kubernetes API | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying Garage Storage Solution | `string` | `"garage"` | no |
| <a name="input_observability_namespace"></a> [observability\_namespace](#input\_observability\_namespace) | Namespace where all components for observability are deployed | `string` | `null` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying Garage Storage Solution | `string` | `"cloud"` | no |
| <a name="input_proxy_image"></a> [proxy\_image](#input\_proxy\_image) | Docker image to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"nginx"` | no |
| <a name="input_proxy_repository"></a> [proxy\_repository](#input\_proxy\_repository) | Repository to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"docker.io/library"` | no |
| <a name="input_proxy_tag"></a> [proxy\_tag](#input\_proxy\_tag) | Docker tag to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"1.29.0"` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository to be used for deployment of Garage Storage Solution | `string` | `"dxflrs"` | no |
| <a name="input_required_access_keys"></a> [required\_access\_keys](#input\_required\_access\_keys) | Access Keys required to be configured within the Garage Cluster | <pre>list(object({<br/>    name         = string<br/>    createBucket = bool<br/>    permissions = list(object({<br/>      bucket = string<br/>      owner  = bool<br/>      read   = bool<br/>      write  = bool<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_required_buckets"></a> [required\_buckets](#input\_required\_buckets) | Buckets to deploy in the Garage Cluster | `list(string)` | n/a | yes |
| <a name="input_required_storage"></a> [required\_storage](#input\_required\_storage) | Size of the disks to configure Garage Storage with | `number` | `5` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | Docker tag to be used for deployment of Garage Storage Solution | `string` | `"v2.0.0"` | no |
| <a name="input_ui_image"></a> [ui\_image](#input\_ui\_image) | Docker image to be used for deployment of Garage UI | `string` | `"garage-ui"` | no |
| <a name="input_ui_ingress_certificate_name"></a> [ui\_ingress\_certificate\_name](#input\_ui\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with Garage UI | `string` | `"garage-ui-ingress-certificate"` | no |
| <a name="input_ui_internal_certificate_name"></a> [ui\_internal\_certificate\_name](#input\_ui\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with the UI component of Garage Storage Solution | `string` | `"garage-ui-internal-certificate"` | no |
| <a name="input_ui_repository"></a> [ui\_repository](#input\_ui\_repository) | Repository to be used for deployment of Garage UI | `string` | `"docker.io/noooste"` | no |
| <a name="input_ui_tag"></a> [ui\_tag](#input\_ui\_tag) | Docker tag to be used for deployment of Garage UI | `string` | `"v0.2.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_garage_internal_certificate_secret"></a> [garage\_internal\_certificate\_secret](#output\_garage\_internal\_certificate\_secret) | Secret name where the Internal Certificate for Garage is stored in |
| <a name="output_garage_namespace"></a> [garage\_namespace](#output\_garage\_namespace) | Namespace where Garage Storage Solution is deployed in |

## Examples

**1. Basic Deployment of the Garage S3 Object Storage Platform with internal TLS certificates, observability and UI Deployment turned off (S3 API will be still available)**

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

# Garage Deployment for an S3 compatible object storage solution
module "garage" {
  source = "../modules/garage"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

  // Certificates Details
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

  // Enabling and disabling features
  enable_internal_tls_certificates = false
  enable_ui                        = false
  enable_observability             = false

  depends_on = [module.openbao]
}
```

**2. Deployment of Garage S3 Object Storage Platform with UI deployment enabled**

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

  // Certificates Details
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

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
  enable_ui                        = true
  enable_observability             = false

  depends_on = [module.helm]
}

# Garage Deployment for an S3 compatible object storage solution
module "garage" {
  source = "../modules/garage"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

  // Certificates Details
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

  // Enabling and disabling features
  enable_internal_tls_certificates = false
  enable_ui                        = true
  enable_observability             = false

  depends_on = [module.openbao]
}
```

**3. Deployment of Garage S3 Object Storage Platform with Observability Enabled**

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

# Complete Observability Stack Deployment
module "observability" {
  source = "../modules/observability"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Certificates Details
  cloudflare_token    = var.cloudflare_token
  cloudflare_email    = var.cloudflare_email
  domain              = var.domain

  // Enabling and disabling features
  enable_internal_tls_certificates = false

  depends_on = [module.helm]
}

# OpenBao Secrets Management Solution deployment
module "openbao" {
  source = "../modules/openbao"

  // Certificates Details
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
  enable_internal_tls_certificates = false
  enable_ui                        = true
  enable_observability             = true

  depends_on = [module.helm]
}

# Garage Deployment for an S3 compatible object storage solution
module "garage" {
  source = "../modules/garage"

  // Cluster Secret Store Details
  cluster_secret_store_name = module.openbao.cluster_secret_store_name

  // Cluster sizing details
  cluster_size = "small"

  // Certificates Details
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
  enable_internal_tls_certificates = false
  enable_ui                        = true
  enable_observability             = true

  depends_on = [module.observability, module.openbao]
}
```

**4. Deployment of Garage S3 Object Storage Platform with Internal TLS Certificates Enabled**

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
```
