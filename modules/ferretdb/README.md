## necronizer's cloud ferret module

OpenTofu Module to deploy [FerretDB](https://www.ferretdb.com/) (MongoDB) Database on the Kubernetes Cluster

Required Modules to deploy FerretDB Database:
1. [Helm](../helm)
2. [Cluster Issuer](../cluster-issuer)
3. [Garage](../garage)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.ferretdb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_manifest.barman_object_store](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.client_certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.client_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.client_streaming_replica_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ferret_cluster_image_catalog](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.server_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.server_certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.server_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.cnpg_network_policy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.ferret_network_policy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_pod_disruption_budget_v1.cnpg_pdb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_pod_disruption_budget_v1.ferret_pdb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_secret.client_database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.ferret_database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.garage_certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.garage_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.ferret_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [random_password.client_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.ferret_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying Ferret Database | `string` | `"ferret"` | no |
| <a name="input_backup_bucket_name"></a> [backup\_bucket\_name](#input\_backup\_bucket\_name) | Name of the bucket for storing PITR Backups in Garage | `string` | n/a | yes |
| <a name="input_client_certificate_authority_name"></a> [client\_certificate\_authority\_name](#input\_client\_certificate\_authority\_name) | Name of the Certificate Authority to be used with Ferret Client | `string` | `"ferretdb-client-certificate-authority"` | no |
| <a name="input_client_issuer_name"></a> [client\_issuer\_name](#input\_client\_issuer\_name) | Name of the Issuer to be used with Ferret Client | `string` | `"ferretdb-client-issuer"` | no |
| <a name="input_client_streaming_replica_certificate_name"></a> [client\_streaming\_replica\_certificate\_name](#input\_client\_streaming\_replica\_certificate\_name) | Name of the Certificate to be used with Ferret Streaming Replica Client | `string` | `"ferretdb-streaming-replica-client-certificate"` | no |
| <a name="input_clients"></a> [clients](#input\_clients) | Object List of clients who need databases and users to be configured for | <pre>list(object({<br/>    namespace          = string<br/>    user               = string<br/>    database           = string<br/>    derRequired        = bool<br/>    privateKeyEncoding = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Ferret Database Cluster to be created | `string` | `"ferret-postgresql-cluster"` | no |
| <a name="input_cluster_postgresql_version"></a> [cluster\_postgresql\_version](#input\_cluster\_postgresql\_version) | Version of Ferret Database to use and deploy | `number` | `17` | no |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | Number of pods to deploy for the Ferret Cluster | `number` | `2` | no |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying Ferret Database | `string` | `"India"` | no |
| <a name="input_garage_certificate_authority"></a> [garage\_certificate\_authority](#input\_garage\_certificate\_authority) | Name of the Certificate Authority associated with the Garage Storage Solution | `string` | n/a | yes |
| <a name="input_garage_configuration"></a> [garage\_configuration](#input\_garage\_configuration) | Garage Configuration for storing PITR Backups | `string` | n/a | yes |
| <a name="input_garage_namespace"></a> [garage\_namespace](#input\_garage\_namespace) | Namespace for the Garage Deployment for storing PITR Backups | `string` | n/a | yes |
| <a name="input_kubernetes_api_ip"></a> [kubernetes\_api\_ip](#input\_kubernetes\_api\_ip) | IP Address for the Kubernetes API | `string` | n/a | yes |
| <a name="input_kubernetes_api_port"></a> [kubernetes\_api\_port](#input\_kubernetes\_api\_port) | Port for the Kubernetes API | `number` | n/a | yes |
| <a name="input_kubernetes_api_protocol"></a> [kubernetes\_api\_protocol](#input\_kubernetes\_api\_protocol) | Protocol for the Kubernetes API | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying Ferret Database | `string` | `"ferret"` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying Ferret Database | `string` | `"cloud"` | no |
| <a name="input_server_certificate_authority_name"></a> [server\_certificate\_authority\_name](#input\_server\_certificate\_authority\_name) | Name of the Certificate Authority to be used with Ferret Server | `string` | `"ferretdb-server-certificate-authority"` | no |
| <a name="input_server_certificate_name"></a> [server\_certificate\_name](#input\_server\_certificate\_name) | Name of the Certificate to be used with Ferret Server | `string` | `"ferretdb-server-certificate"` | no |
| <a name="input_server_issuer_name"></a> [server\_issuer\_name](#input\_server\_issuer\_name) | Name of the Issuer to be used with Ferret Server | `string` | `"ferretdb-server-issuer"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace where FerretDB is deployed in |
