<!-- BEGIN_TF_DOCS -->
## necronizer's cloud cloudnative pg module

OpenTofu Module to deploy [Cloudnative PG](https://cloudnative-pg.io/) PostgreSQL Database on the Kubernetes Cluster

Required Modules to deploy Cloudnative PG PostgreSQL Database:
1. [Helm](../helm)
2. [Cluster Issuer](../cluster-issuer)
3. [MinIO](../minio)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.client_certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.client_certificates](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.client_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.client_keycloak_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.client_streaming_replica_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.databases](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.keycloak_database](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.server_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.server_certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.server_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.client_database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.keycloak_database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.minio_certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.postgres_user_minio_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_password.client_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.keycloak_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying PostgreSQL Database | `string` | `"postgres"` | no |
| <a name="input_backup_bucket_name"></a> [backup\_bucket\_name](#input\_backup\_bucket\_name) | Name of the bucket for storing PITR Backups in MinIO | `string` | n/a | yes |
| <a name="input_client_certificate_authority_name"></a> [client\_certificate\_authority\_name](#input\_client\_certificate\_authority\_name) | Name of the Certificate Authority to be used with PostgreSQL Client | `string` | `"postgresql-client-certificate-authority"` | no |
| <a name="input_client_issuer_name"></a> [client\_issuer\_name](#input\_client\_issuer\_name) | Name of the Issuer to be used with PostgreSQL Client | `string` | `"postgresql-client-issuer"` | no |
| <a name="input_client_streaming_replica_certificate_name"></a> [client\_streaming\_replica\_certificate\_name](#input\_client\_streaming\_replica\_certificate\_name) | Name of the Certificate to be used with PostgreSQL Streaming Replica Client | `string` | `"postgresql-streaming-replica-client-certificate"` | no |
| <a name="input_clients"></a> [clients](#input\_clients) | Object List of clients who need databases and users to be configured for | <pre>list(object({<br/>    namespace          = string<br/>    user               = string<br/>    database           = string<br/>    derRequired        = bool<br/>    privateKeyEncoding = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the PostgreSQL Database Cluster to be created | `string` | `"postgresql-cluster"` | no |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying PostgreSQL Database | `string` | `"India"` | no |
| <a name="input_minio_certificate_authority"></a> [minio\_certificate\_authority](#input\_minio\_certificate\_authority) | Name of the Certificate Authority associated with the MinIO Storage Solution | `string` | n/a | yes |
| <a name="input_minio_namespace"></a> [minio\_namespace](#input\_minio\_namespace) | Namespace for the MinIO Deployment for storing PITR Backups | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying PostgreSQL Database | `string` | `"postgres"` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying PostgreSQL Database | `string` | `"cloud"` | no |
| <a name="input_postgres_user_minio_configuration"></a> [postgres\_user\_minio\_configuration](#input\_postgres\_user\_minio\_configuration) | MinIO Configuration for storing PITR Backups | `string` | n/a | yes |
| <a name="input_server_certificate_authority_name"></a> [server\_certificate\_authority\_name](#input\_server\_certificate\_authority\_name) | Name of the Certificate Authority to be used with PostgreSQL Server | `string` | `"postgresql-server-certificate-authority"` | no |
| <a name="input_server_certificate_name"></a> [server\_certificate\_name](#input\_server\_certificate\_name) | Name of the Certificate to be used with PostgreSQL Server | `string` | `"postgresql-server-certificate"` | no |
| <a name="input_server_issuer_name"></a> [server\_issuer\_name](#input\_server\_issuer\_name) | Name of the Issuer to be used with PostgreSQL Server | `string` | `"postgresql-server-issuer"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace where the PostgreSQL Database is deployed in |
| <a name="output_server-certificate-authority"></a> [server-certificate-authority](#output\_server-certificate-authority) | Certificate Authority being used with PostgreSQL Database |
<!-- END_TF_DOCS -->
