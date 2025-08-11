## necronizer's cloud garage module

OpenTofu Module to deploy [Garage](https://garagehq.deuxfleurs.fr/) Object Storage on the Kubernetes Cluster

Required Modules to deploy Garage Object Storage:
1. [Cluster Issuer](../cluster-issuer)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role.garage_crds](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.garage_crds_rolebindings](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map.configurator-options](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.garage_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.nginx_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_ingress_v1.api_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_job.configurator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_manifest.api_ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.public_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.garage_configurator_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.garage_configurator_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret.admin_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.cloudflare_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.rpc_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.garage-headless](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.garage-service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service_account.garage_configurator_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.garage_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_stateful_set.statefulset](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |
| [random_bytes.rpc_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/bytes) | resource |
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acme_server"></a> [acme\_server](#input\_acme\_server) | URL for the ACME Server to be used, defaults to production URL for LetsEncrypt | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_api_ingress_certificate_name"></a> [api\_ingress\_certificate\_name](#input\_api\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with Garage API | `string` | `"garage-api-ingress-certificate"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying Garage Storage Solution | `string` | `"garage"` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with Garage Storage Solution | `string` | `"garage-certificate-authority"` | no |
| <a name="input_cloudflare_email"></a> [cloudflare\_email](#input\_cloudflare\_email) | Email for generating Ingress Certificates to be associated with Garage Storage Solution | `string` | n/a | yes |
| <a name="input_cloudflare_issuer_name"></a> [cloudflare\_issuer\_name](#input\_cloudflare\_issuer\_name) | Name of the Cloudflare Issuer to be associated with Garage Storage Solution | `string` | `"garage-cloudflare-issuer"` | no |
| <a name="input_cloudflare_token"></a> [cloudflare\_token](#input\_cloudflare\_token) | Token for generating Ingress Certificates to be associated with Garage Storage Solution | `string` | n/a | yes |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_cluster_nodes"></a> [cluster\_nodes](#input\_cluster\_nodes) | Number of nodes to deploy Garage Cluster with | `number` | `3` | no |
| <a name="input_configurator_image"></a> [configurator\_image](#input\_configurator\_image) | Docker image to be used for deployment of Garage Configurator | `string` | `"garage-configurator"` | no |
| <a name="input_configurator_repository"></a> [configurator\_repository](#input\_configurator\_repository) | Repository to be used for deployment of Garage Configurator | `string` | `"quay.io/necronizerslab"` | no |
| <a name="input_configurator_tag"></a> [configurator\_tag](#input\_configurator\_tag) | Docker tag to be used for deployment of Garage Configurator | `string` | `"0.8.10"` | no |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying Garage Storage Solution | `string` | `"India"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for which Ingress Certificate is to be generated for | `string` | n/a | yes |
| <a name="input_garage_cluster_name"></a> [garage\_cluster\_name](#input\_garage\_cluster\_name) | Name of the Garage Cluster | `string` | `"garage"` | no |
| <a name="input_garage_node_tags"></a> [garage\_node\_tags](#input\_garage\_node\_tags) | Node Tags to use to configure Garage nodes with | `list(string)` | <pre>[<br/>  "garage",<br/>  "node"<br/>]</pre> | no |
| <a name="input_garage_region"></a> [garage\_region](#input\_garage\_region) | Region to be used for the Garage Storage | `string` | `"garage"` | no |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name for which Ingress Certificate is to be generated for | `string` | `"storage"` | no |
| <a name="input_image"></a> [image](#input\_image) | Docker image to be used for deployment of Garage Storage Solution | `string` | `"amd64_garage"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with Garage Storage Solution | `string` | `"garage-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with Garage Storage Solution | `string` | `"garage-certificate-issuer"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying Garage Storage Solution | `string` | `"garage"` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying Garage Storage Solution | `string` | `"cloud"` | no |
| <a name="input_proxy_image"></a> [proxy\_image](#input\_proxy\_image) | Docker image to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"nginx"` | no |
| <a name="input_proxy_repository"></a> [proxy\_repository](#input\_proxy\_repository) | Repository to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"docker.io/library"` | no |
| <a name="input_proxy_tag"></a> [proxy\_tag](#input\_proxy\_tag) | Docker tag to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"1.29.0"` | no |
| <a name="input_replication_namespaces"></a> [replication\_namespaces](#input\_replication\_namespaces) | Namespaces to which Certificate Authority can be replicated to | `string` | `"postgres"` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository to be used for deployment of Garage Storage Solution | `string` | `"dxflrs"` | no |
| <a name="input_required_access_keys"></a> [required\_access\_keys](#input\_required\_access\_keys) | Access Keys required to be configured within the Garage Cluster | <pre>list(object({<br/>    name         = string<br/>    createBucket = bool<br/>    permissions = list(object({<br/>      bucket = string<br/>      owner  = bool<br/>      read   = bool<br/>      write  = bool<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_required_buckets"></a> [required\_buckets](#input\_required\_buckets) | Buckets to deploy in the Garage Cluster | `list(string)` | n/a | yes |
| <a name="input_required_storage"></a> [required\_storage](#input\_required\_storage) | Size of the disks to configure Garage Storage with | `number` | `5` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | Docker tag to be used for deployment of Garage Storage Solution | `string` | `"v2.0.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_garage_internal_certificate_secret"></a> [garage\_internal\_certificate\_secret](#output\_garage\_internal\_certificate\_secret) | Secret name where the Internal Certificate for Garage is stored in |
| <a name="output_garage_namespace"></a> [garage\_namespace](#output\_garage\_namespace) | Namespace where Garage Storage Solution is deployed in |
