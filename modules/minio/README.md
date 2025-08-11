<!-- BEGIN_TF_DOCS -->
## [DEPRECATED] necronizer's cloud minio module

OpenTofu Module to deploy [MinIO](https://min.io/) Object Storage on the Kubernetes Cluster

Required Modules to deploy MinIO Object Storage:
1. [Helm](../helm)
2. [Cluster Issuer](../cluster-issuer)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_ingress_v1.api_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_ingress_v1.ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_manifest.api_ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.minio_tenant](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.operator_certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.operator_internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.operator_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.public_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.cloudflare_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.postgres_user_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.storage_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.tenant_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.user_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [null_resource.restart_deployment](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.postgres_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.root_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.user_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acme_server"></a> [acme\_server](#input\_acme\_server) | URL for the ACME Server to be used, defaults to production URL for LetsEncrypt | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_admin_user"></a> [admin\_user](#input\_admin\_user) | Name of the admin user for accessing MinIO Tenant | `string` | `"minio.admin"` | no |
| <a name="input_api_ingress_certificate_name"></a> [api\_ingress\_certificate\_name](#input\_api\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with MinIO API Storage Solution | `string` | `"minio-api-ingress-certificate"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying MinIO Storage Solution | `string` | `"minio"` | no |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | List of buckets for which MinIO Tenant needs to be deployed with | `list(string)` | `[]` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with MinIO Storage Solution | `string` | `"minio-certificate-authority"` | no |
| <a name="input_cloudflare_email"></a> [cloudflare\_email](#input\_cloudflare\_email) | Email for generating Ingress Certificates to be associated with MinIO Storage Solution | `string` | n/a | yes |
| <a name="input_cloudflare_issuer_name"></a> [cloudflare\_issuer\_name](#input\_cloudflare\_issuer\_name) | Name of the Cloudflare Issuer to be associated with MinIO Storage Solution | `string` | `"minio-cloudflare-issuer"` | no |
| <a name="input_cloudflare_token"></a> [cloudflare\_token](#input\_cloudflare\_token) | Token for generating Ingress Certificates to be associated with MinIO Storage Solution | `string` | n/a | yes |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying MinIO Storage Solution | `string` | `"India"` | no |
| <a name="input_database_replication_namespaces"></a> [database\_replication\_namespaces](#input\_database\_replication\_namespaces) | Namespaces to which Certificate Authority can be replicated to | `string` | `"postgres"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for which Ingress Certificate is to be generated for | `string` | n/a | yes |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name for which Ingress Certificate is to be generated for | `string` | `"storage"` | no |
| <a name="input_ingress_certificate_name"></a> [ingress\_certificate\_name](#input\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with MinIO Storage Solution | `string` | `"minio-ingress-certificate"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with MinIO Storage Solution | `string` | `"minio-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with MinIO Storage Solution | `string` | `"minio-certificate-issuer"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying MinIO Storage Solution | `string` | `"minio"` | no |
| <a name="input_operator_certificate_authority_name"></a> [operator\_certificate\_authority\_name](#input\_operator\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with MinIO Operator | `string` | `"operator-ca-tls"` | no |
| <a name="input_operator_internal_certificate_name"></a> [operator\_internal\_certificate\_name](#input\_operator\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with MinIO Operator | `string` | `"sts-certmanager-cert"` | no |
| <a name="input_operator_issuer_name"></a> [operator\_issuer\_name](#input\_operator\_issuer\_name) | Name of the Issuer to be associated with MinIO Operator | `string` | `"operator-ca-issuer"` | no |
| <a name="input_operator_namespace"></a> [operator\_namespace](#input\_operator\_namespace) | Namespace where the MinIO Operator is deployed in | `string` | n/a | yes |
| <a name="input_operator_tenant_certificate_name"></a> [operator\_tenant\_certificate\_name](#input\_operator\_tenant\_certificate\_name) | Name of the Certificate of the Tenant to be used by the MinIO Operator | `string` | `"operator-ca-tls-tenant"` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying MinIO Storage Solution | `string` | `"cloud"` | no |
| <a name="input_postgresql_backup_bucket"></a> [postgresql\_backup\_bucket](#input\_postgresql\_backup\_bucket) | Bucket to be used for storing PostgreSQL PITR Backups | `string` | `"postgres"` | no |
| <a name="input_storage_configuration_name"></a> [storage\_configuration\_name](#input\_storage\_configuration\_name) | Name of the secret for storing MinIO Storage Configuration | `string` | `"storage-configuration"` | no |
| <a name="input_users"></a> [users](#input\_users) | List of users for which MinIO Tenant needs to be deployed with | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate-authority-name"></a> [certificate-authority-name](#output\_certificate-authority-name) | Certificate Authority Name for the MinIO Tenant |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace where MinIO is deployed |
| <a name="output_postgres-backup-bucket"></a> [postgres-backup-bucket](#output\_postgres-backup-bucket) | Bucket to be used for storing PostgreSQL PITR Backups |
| <a name="output_postgres-user-minio-configuration"></a> [postgres-user-minio-configuration](#output\_postgres-user-minio-configuration) | PostgreSQL Configuration for storing PITR backups |
<!-- END_TF_DOCS -->
