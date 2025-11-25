<!-- BEGIN_TF_DOCS -->
## necronizer's cloud keycloak module

OpenTofu Module to deploy [Keycloak](https://www.keycloak.org/) Identity Management on the Kubernetes Cluster

Required Modules to deploy Keycloak Identity Management:
1. [Cluster Issuer](../cluster-issuer)
2. [Cloudnative PG](../cnpg)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.realm_configuration](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_ingress_v1.ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_manifest.certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ingress_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.internal_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.public_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.keycloak_network_access_policy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_pod_disruption_budget_v1.keycloak_pdb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_secret.cloudflare_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.database_client_certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.database_server_certificate_authority](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.keycloak_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.realm_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.keycloak_discovery](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.keycloak_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_stateful_set.keycloak_cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |
| [random_password.keycloak_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.tester_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acme_server"></a> [acme\_server](#input\_acme\_server) | URL for the ACME Server to be used, defaults to production URL for LetsEncrypt | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | App name for deploying Keycloak Identity Platform solution | `string` | `"keycloak"` | no |
| <a name="input_certificate_authority_name"></a> [certificate\_authority\_name](#input\_certificate\_authority\_name) | Name of the Certificate Authority to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-certificate-authority"` | no |
| <a name="input_cloudflare_email"></a> [cloudflare\_email](#input\_cloudflare\_email) | Email for generating Ingress Certificates to be associated with Keycloak Identity Platform solution | `string` | n/a | yes |
| <a name="input_cloudflare_issuer_name"></a> [cloudflare\_issuer\_name](#input\_cloudflare\_issuer\_name) | Name of the Cloudflare Issuer to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-cloudflare-issuer"` | no |
| <a name="input_cloudflare_token"></a> [cloudflare\_token](#input\_cloudflare\_token) | Token for generating Ingress Certificates to be associated with Keycloak Identity Platform solution | `string` | n/a | yes |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name for the Cluster Issuer to be used to generate internal self signed certificates | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Database Cluster Name to allow Network Connections to | `string` | n/a | yes |
| <a name="input_country_name"></a> [country\_name](#input\_country\_name) | Country name for deploying Keycloak Identity Platform solution | `string` | `"India"` | no |
| <a name="input_database_client_certificate_name"></a> [database\_client\_certificate\_name](#input\_database\_client\_certificate\_name) | Client Certificate to be used for Keycloak User | `string` | n/a | yes |
| <a name="input_database_credentials"></a> [database\_credentials](#input\_database\_credentials) | Name of the secret which contains the database credentials for Keycloak | `string` | n/a | yes |
| <a name="input_database_server_certificate_authority_name"></a> [database\_server\_certificate\_authority\_name](#input\_database\_server\_certificate\_authority\_name) | Server Certificate Authority being used for the database | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain for which Ingress Certificate is to be generated for | `string` | n/a | yes |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Host name for which Ingress Certificate is to be generated for | `string` | `"auth"` | no |
| <a name="input_ingress_certificate_name"></a> [ingress\_certificate\_name](#input\_ingress\_certificate\_name) | Name of the Ingress Certificate to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-ingress-certificate"` | no |
| <a name="input_internal_certificate_name"></a> [internal\_certificate\_name](#input\_internal\_certificate\_name) | Name of the Internal Certificate to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-internal-certificate"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the Issuer to be associated with Keycloak Identity Platform solution | `string` | `"keycloak-certificate-issuer"` | no |
| <a name="input_keycloak_credentials"></a> [keycloak\_credentials](#input\_keycloak\_credentials) | Name of the secret which contains the credentials for the Keycloak Cluster | `string` | `"default-credentials"` | no |
| <a name="input_keycloak_environment_variables"></a> [keycloak\_environment\_variables](#input\_keycloak\_environment\_variables) | Environment variables for Keycloak Configuration | `list` | <pre>[<br/>  {<br/>    "name": "KC_HTTP_PORT",<br/>    "value": "8080"<br/>  },<br/>  {<br/>    "name": "KC_HTTPS_PORT",<br/>    "value": "8443"<br/>  },<br/>  {<br/>    "name": "KC_HTTPS_CERTIFICATE_FILE",<br/>    "value": "/mnt/certs/tls/tls.crt"<br/>  },<br/>  {<br/>    "name": "KC_HTTPS_CERTIFICATE_KEY_FILE",<br/>    "value": "/mnt/certs/tls/tls.key"<br/>  },<br/>  {<br/>    "name": "KC_DB_URL",<br/>    "value": "jdbc:postgresql://postgresql-cluster-rw.postgres.svc/keycloak?ssl=true&sslmode=verify-full&sslrootcert=/mnt/certs/database/certificate-authority/ca.crt&sslcert=/mnt/certs/database/certificate/tls.crt&sslkey=/mnt/certs/database/certificate/key.der"<br/>  },<br/>  {<br/>    "name": "KC_DB_POOL_INITIAL_SIZE",<br/>    "value": "1"<br/>  },<br/>  {<br/>    "name": "KC_DB_POOL_MIN_SIZE",<br/>    "value": "1"<br/>  },<br/>  {<br/>    "name": "KC_DB_POOL_MAX_SIZE",<br/>    "value": "3"<br/>  },<br/>  {<br/>    "name": "KC_HEALTH_ENABLED",<br/>    "value": "true"<br/>  },<br/>  {<br/>    "name": "KC_CACHE",<br/>    "value": "ispn"<br/>  },<br/>  {<br/>    "name": "KC_CACHE_STACK",<br/>    "value": "jdbc-ping"<br/>  },<br/>  {<br/>    "name": "KC_PROXY",<br/>    "value": "passthrough"<br/>  },<br/>  {<br/>    "name": "KC_TRUSTSTORE_PATHS",<br/>    "value": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"<br/>  }<br/>]</pre> | no |
| <a name="input_keycloak_ports"></a> [keycloak\_ports](#input\_keycloak\_ports) | Keycloak Ports Configuration | `list` | <pre>[<br/>  {<br/>    "containerPort": "8443",<br/>    "name": "https",<br/>    "protocol": "TCP"<br/>  },<br/>  {<br/>    "containerPort": "8080",<br/>    "name": "http",<br/>    "protocol": "TCP"<br/>  },<br/>  {<br/>    "containerPort": "9000",<br/>    "name": "management",<br/>    "protocol": "TCP"<br/>  },<br/>  {<br/>    "containerPort": "7800",<br/>    "name": "discovery",<br/>    "protocol": "TCP"<br/>  }<br/>]</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to be used for deploying Keycloak Identity Platform solution | `string` | `"keycloak"` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Organization name for deploying Keycloak Identity Platform solution | `string` | `"cloud"` | no |
| <a name="input_postgres_namespace"></a> [postgres\_namespace](#input\_postgres\_namespace) | Namespace for the PostgreSQL Deployment for database connections | `string` | n/a | yes |
| <a name="input_realm_settings"></a> [realm\_settings](#input\_realm\_settings) | Realm Settings for pre-installing a realm with Keycloak | <pre>object({<br/>    display_name               = string<br/>    application_name           = string<br/>    base_url                   = string<br/>    valid_login_redirect_path  = string<br/>    valid_logout_redirect_path = string<br/>    smtp_host                  = string<br/>    smtp_port                  = number<br/>    smtp_mail                  = string<br/>    smtp_username              = string<br/>    smtp_password              = string<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
