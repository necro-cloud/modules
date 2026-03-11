## necronizer's cloud openbao module

OpenTofu Module to deploy [OpenBao](https://openbao.org/) Secrets Management Solution on the Kubernetes Cluster.

Required Modules to deploy OpenBao Secrets Manageemnt Solution:
1. [Cluster Issuer](../cluster-issuer)
2. [Observability](../observability)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Resources

| Name | Type |
|------|------|
| [helm_release.openbao](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map.configurator_script](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_ingress_v1.ui_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_job.configurator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.public_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.openbao_network_access_policy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_role.configurator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.configurator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret.cloudflare_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.static_unseal_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.configurator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [random_id.static_unseal_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_namespaces"></a> [access\_namespaces](#input\_access\_namespaces) | Namespaces requiring accesses to the OpenBao Cluster in a comma seperated list | `string` |
| <a name="input_acme_server"></a> [acme\_server](#input\_acme\_server) | URL for the ACME Server to be used, defaults to production URL for LetsEncrypt | `string` | `"https://acme-v02
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying OpenBao Secrets Management Solution | `string` | `"openbao"` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with OpenBao
| <a name="input_cloudflare_email"></a> [cloudflare\_email](#input\_cloudflare\_email) | Email for generating Ingress Certificates to be associated with OpenBao Secrets Management Solu
| <a name="input_cloudflare_issuer_name"></a> [cloudflare\_issuer\_name](#input\_cloudflare\_issuer\_name) | Name of the Cloudflare Issuer to be associated with OpenBao Secrets Management Solution | `string` | `"secrets-cloudflare-issuer"` | no |
| <a name="input_cloudflare_token"></a> [cloudflare\_token](#input\_cloudflare\_token) | Token for generating Ingress Certificates to be associated with OpenBao Secrets Management Solution | `string` | n/a | yes |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | Number of pods to be deployed for High Availability for OpenBao Secrets Management Solution | `number` | `3` | no |
| <a name="input_configurator_image"></a> [configurator\_image](#input\_configurator\_image) | Docker image to be used for deployment of OpenBao Configurator | `string` | `"openbao"` | no |
| <a name="input_configurator_repository"></a> [configurator\_repository](#input\_configurator\_repository) | Repository to be used for deployment of OpenBao Configurator | `string` | `"quay.io/openbao"` | no |
| <a name="input_configurator_tag"></a> [configurator\_tag](#input\_configurator\_tag) | Docker tag to be used for deployment of OpenBao Configurator | `string` | `"2.5.1"` | no |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying OpenBao Secrets Management Solution | `string` | `"India"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for which Ingress Certificate is to be generated for | `string` | n/a | yes |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name for which Ingress Certificate is to be generated for | `string` | `"secrets"` | no |
| <a name="input_ingress_certificate_name"></a> [ingress\_certificate\_name](#input\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with OpenBao Secrets Management Solution | `string` | `"secrets-ingress-certificate"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with OpenBao Secrets Management Solution | `string` | `"secrets-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with OpenBao Secrets Management Solution | `string` | `"secrets-certificate-issuer"` | no |
| <a name="input_kubernetes_api_ip"></a> [kubernetes\_api\_ip](#input\_kubernetes\_api\_ip) | IP Address for the Kubernetes API | `string` | n/a | yes |
| <a name="input_kubernetes_api_port"></a> [kubernetes\_api\_port](#input\_kubernetes\_api\_port) | Port for the Kubernetes API | `number` | n/a | yes |
| <a name="input_kubernetes_api_protocol"></a> [kubernetes\_api\_protocol](#input\_kubernetes\_api\_protocol) | Protocol for the Kubernetes API | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying OpenBao Secrets Management Solution | `string` | `"openbao"` | no |
| <a name="input_observability_namespace"></a> [observability\_namespace](#input\_observability\_namespace) | Namespace where all components for observability are deployed | `string` | n/a | yes |
| <a name="input_openbao_configuration"></a> [openbao\_configuration](#input\_openbao\_configuration) | Dictionary filled with OpenBao Configuration Details | `map(string)` | <pre>{<br/>  "chart": "openbao",<br/>  "name": "openbao",<br/>  "repository": "https://openbao.github.io/openbao-helm",<br/>  "version": "0.25.6"<br/>}</pre> | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying OpenBao Secrets Management Solution | `string` | `"cloud"` | no |

## Outputs

No outputs.
