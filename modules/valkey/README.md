## necronizer's cloud valkey module

OpenTofu Module to deploy [Valkey](https://valkey.io/) In Memory Database on the Kubernetes Cluster

Required Modules to deploy Valkey In Memory Database:
1. [Cluster Issuer](../cluster-issuer)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.valkey_conf](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.valkey_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.headless_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.primary_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.replica_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_stateful_set.valkey_cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |
| [random_password.valkey_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying Valkey Cache Solution | `string` | `"valkey"` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with Valkey Cache Solution | `string` | `"valkey-certificate-authority"` | no |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying Valkey Cache Solution | `string` | `"India"` | no |
| <a name="input_image"></a> [image](#input\_image) | Docker image to be used for deployment of Valkey | `string` | `"valkey"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with Valkey Cache Solution | `string` | `"valkey-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with Valkey Cache Solution | `string` | `"valkey-certificate-issuer"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying Valkey Cache Solution | `string` | `"valkey"` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying Valkey Cache Solution | `string` | `"cloud"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of replicas to run for Valkey Cluster | `number` | `3` | no |
| <a name="input_replication_namespaces"></a> [replication\_namespaces](#input\_replication\_namespaces) | Namespaces where the certificates | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository to be used for deployment of Valkey | `string` | `"docker.io/valkey"` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | Docker tag to be used for deployment of Valkey | `string` | `"8.1.3"` | no |

## Outputs

No outputs.
