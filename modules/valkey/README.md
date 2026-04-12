## necronizer's cloud valkey module

OpenTofu Module to deploy [Valkey](https://valkey.io/) In Memory Database on the Kubernetes Cluster

Required Modules to deploy Valkey In Memory Database:
1. [Cluster Issuer](../cluster-issuer)
2. [Observability](../observability)
3. [OpenBao](../openbao)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.ui_nginx_conf](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.valkey_conf](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_deployment.valkey_ui](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.ui_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.middleware_buffering](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.middleware_rewrite](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.password_generator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.public_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_ui_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.push_valkey_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.transport](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ui_credentials_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ui_internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.valkey_credentials_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.valkey_network_access_policy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_pod_disruption_budget_v1.valkey_pdb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_secret.cloudflare_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.redis_commander_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.headless_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.primary_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.replica_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.ui_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_stateful_set.valkey_cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_namespaces"></a> [access\_namespaces](#input\_access\_namespaces) | Namespaces which require access to Valkey through certificates and network | `string` | n/a | yes |
| <a name="input_acme_server"></a> [acme\_server](#input\_acme\_server) | URL for the ACME Server to be used, defaults to production URL for LetsEncrypt | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying Valkey Cache Solution | `string` | `"valkey"` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with Valkey Cache Solution | `string` | `"valkey-certificate-authority"` | no |
| <a name="input_cloudflare_email"></a> [cloudflare\_email](#input\_cloudflare\_email) | Email for generating Ingress Certificates to be associated with OpenBao Secrets Management Solution | `string` | n/a | yes |
| <a name="input_cloudflare_issuer_name"></a> [cloudflare\_issuer\_name](#input\_cloudflare\_issuer\_name) | Name of the Cloudflare Issuer to be associated with OpenBao Secrets Management Solution | `string` | `"secrets-cloudflare-issuer"` | no |
| <a name="input_cloudflare_token"></a> [cloudflare\_token](#input\_cloudflare\_token) | Token for generating Ingress Certificates to be associated with OpenBao Secrets Management Solution | `string` | n/a | yes |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_cluster_secret_store_name"></a> [cluster\_secret\_store\_name](#input\_cluster\_secret\_store\_name) | Name of the cluster secret store to be used for pulling and pushing secrets to OpenBao | `string` | n/a | yes |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying Valkey Cache Solution | `string` | `"India"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for which Ingress Certificate is to be generated for | `string` | n/a | yes |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name for which Ingress Certificate is to be generated for | `string` | `"memory"` | no |
| <a name="input_image"></a> [image](#input\_image) | Docker image to be used for deployment of Valkey | `string` | `"valkey"` | no |
| <a name="input_ingress_certificate_name"></a> [ingress\_certificate\_name](#input\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with Redis Commander | `string` | `"valkey-ui-ingress-certificate"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with Valkey Cache Solution | `string` | `"valkey-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with Valkey Cache Solution | `string` | `"valkey-certificate-issuer"` | no |
| <a name="input_metrics_image"></a> [metrics\_image](#input\_metrics\_image) | Docker image to be used for deployment of Valkey Metrics | `string` | `"redis_exporter"` | no |
| <a name="input_metrics_repository"></a> [metrics\_repository](#input\_metrics\_repository) | Repository to be used for deployment of Valkey Metrics | `string` | `"docker.io/oliver006"` | no |
| <a name="input_metrics_tag"></a> [metrics\_tag](#input\_metrics\_tag) | Docker tag to be used for deployment of Valkey Metrics | `string` | `"v1.81.0-alpine"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying Valkey Cache Solution | `string` | `"valkey"` | no |
| <a name="input_observability_namespace"></a> [observability\_namespace](#input\_observability\_namespace) | Namespace where all components for observability are deployed | `string` | n/a | yes |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying Valkey Cache Solution | `string` | `"cloud"` | no |
| <a name="input_proxy_image"></a> [proxy\_image](#input\_proxy\_image) | Docker image to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"nginx"` | no |
| <a name="input_proxy_repository"></a> [proxy\_repository](#input\_proxy\_repository) | Repository to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"docker.io/library"` | no |
| <a name="input_proxy_tag"></a> [proxy\_tag](#input\_proxy\_tag) | Docker tag to be used for deployment of Garage NGINX Proxy for TLS | `string` | `"1.29.0"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of replicas to run for Valkey Cluster | `number` | `3` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository to be used for deployment of Valkey | `string` | `"docker.io/valkey"` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | Docker tag to be used for deployment of Valkey | `string` | `"9.0"` | no |
| <a name="input_ui_image"></a> [ui\_image](#input\_ui\_image) | Docker image to be used for deployment of Redis Commander | `string` | `"redis-commander"` | no |
| <a name="input_ui_internal_certificate_name"></a> [ui\_internal\_certificate\_name](#input\_ui\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with Redis Commander | `string` | `"ui-internal-certificate"` | no |
| <a name="input_ui_repository"></a> [ui\_repository](#input\_ui\_repository) | Repository to be used for deployment of Redis Commander | `string` | `"ghcr.io/joeferner"` | no |
| <a name="input_ui_tag"></a> [ui\_tag](#input\_ui\_tag) | Docker tag to be used for deployment of Redis Commander | `string` | `"0.9.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_valkey_certificates_name"></a> [valkey\_certificates\_name](#output\_valkey\_certificates\_name) | Name of the Internal Certificate to be associated with Valkey Cache Solution |
| <a name="output_valkey_credentials_name"></a> [valkey\_credentials\_name](#output\_valkey\_credentials\_name) | Name of the secret where credentials for Valkey Cache Solution is stored |
| <a name="output_valkey_namespace"></a> [valkey\_namespace](#output\_valkey\_namespace) | Namespace to be used for deploying Valkey Cache Solution |
