<!-- BEGIN_TF_DOCS -->
## necronizer's cloud valkey module

OpenTofu Module to deploy [Valkey](https://valkey.io/) In Memory Database on the Kubernetes Cluster

Required Modules to deploy Valkey In Memory Database:
1. [Cluster Issuer](../cluster-issuer)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.0-pre2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Resources

| Name | Type |
|------|------|
| [helm_release.valkey](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.valkey_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_password.valkey_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying Valkey Cache Solution | `string` | `"valkey"` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with Valkey Cache Solution | `string` | `"valkey-certificate-authority"` | no |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying Valkey Cache Solution | `string` | `"India"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with Valkey Cache Solution | `string` | `"valkey-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with Valkey Cache Solution | `string` | `"valkey-certificate-issuer"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying Valkey Cache Solution | `string` | `"valkey"` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying Valkey Cache Solution | `string` | `"cloud"` | no |
| <a name="input_replication_namespaces"></a> [replication\_namespaces](#input\_replication\_namespaces) | Namespaces where the certificates | `string` | n/a | yes |
| <a name="input_valkey_configuration"></a> [valkey\_configuration](#input\_valkey\_configuration) | Dictionary filled with Valkey Configuration Details | `map(string)` | <pre>{<br/>  "chart": "valkey",<br/>  "create_namespace": false,<br/>  "name": "valkey",<br/>  "repository": "oci://registry-1.docker.io/bitnamicharts",<br/>  "version": "2.4.6"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
