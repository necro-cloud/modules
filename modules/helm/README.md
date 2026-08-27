## [MAIN MODULE] necronizer's cloud required helm charts module

OpenTofu Module to deploy the following required helm charts:
1. [Cert-Manager](https://cert-manager.io/)
2. [Cloudnative PG (including Barman Plugin)](https://cloudnative-pg.io/)
3. [Traefik](https://traefik.io/)
4. [Calico CNI](https://www.tigera.io/project-calico/)
5. [External Secrets](https://external-secrets.io)

## Table of Contents
- [Providers](#providers)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |

## Resources

| Name | Type |
|------|------|
| [helm_release.calico](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cnpg](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cnpg_barman_plugin](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.external_secrets](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.traefik](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_calico_configuration"></a> [calico\_configuration](#input\_calico\_configuration) | Dictionary filled with Calico Configuration Details | `map(string)` | <pre>{<br/>  "chart": "tigera-operator",<br/>  "create_namespace": true,<br/>  "name": "tigera-operator",<br/>  "namespace": "tigera-operator",<br/>  "repository": "https://docs.tigera.io/calico/charts",<br/>  "version": "v3.30.3"<br/>}</pre> | no |
| <a name="input_cert_manager_configuration"></a> [cert\_manager\_configuration](#input\_cert\_manager\_configuration) | Dictionary filled with Cert Manager Operator Configuration Details | `map(string)` | <pre>{<br/>  "chart": "cert-manager",<br/>  "create_namespace": true,<br/>  "name": "cert-manager",<br/>  "namespace": "cert-manager",<br/>  "repository": "https://charts.jetstack.io",<br/>  "version": "v1.19.0"<br/>}</pre> | no |
| <a name="input_cnpg_barman_configuration"></a> [cnpg\_barman\_configuration](#input\_cnpg\_barman\_configuration) | Dictionary filled with Cloud Native PG Barman Configuration Details | `map(string)` | <pre>{<br/>  "chart": "plugin-barman-cloud",<br/>  "name": "cnpg-barman",<br/>  "namespace": "cnpg-system",<br/>  "repository": "https://cloudnative-pg.github.io/charts",<br/>  "version": "v0.2.0"<br/>}</pre> | no |
| <a name="input_cnpg_configuration"></a> [cnpg\_configuration](#input\_cnpg\_configuration) | Dictionary filled with Cloud Native PG Operator Configuration Details | `map(string)` | <pre>{<br/>  "chart": "cloudnative-pg",<br/>  "create_namespace": true,<br/>  "name": "cnpg",<br/>  "namespace": "cnpg-system",<br/>  "repository": "https://cloudnative-pg.github.io/charts",<br/>  "version": "v0.26.0"<br/>}</pre> | no |
| <a name="input_external_secrets_configuration"></a> [external\_secrets\_configuration](#input\_external\_secrets\_configuration) | Dictionary filled with External Secrets Operator Configuration Details | `map(string)` | <pre>{<br/>  "chart": "external-secrets",<br/>  "create_namespace": true,<br/>  "name": "external-secrets",<br/>  "namespace": "external-secrets",<br/>  "repository": "https://charts.external-secrets.io",<br/>  "version": "2.1.0"<br/>}</pre> | no |
| <a name="input_server_node_selector"></a> [server\_node\_selector](#input\_server\_node\_selector) | Node Selector Label Value to be used for deploying required foundation components | `string` | n/a | yes |
| <a name="input_traefik_configuration"></a> [traefik\_configuration](#input\_traefik\_configuration) | Dictionary filled with Traefik Controller Configuration Details | `map(string)` | <pre>{<br/>  "chart": "traefik",<br/>  "create_namespace": "true",<br/>  "name": "traefik",<br/>  "namespace": "traefik",<br/>  "repository": "https://traefik.github.io/charts",<br/>  "version": "v39.0.7"<br/>}</pre> | no |

## Outputs

No outputs.

## Examples

**1. Deployment of all required Helm Charts**

```terraform
# Deploy all required helm charts for deploying the infrastructure
module "helm" {
  source               = "../modules/helm"
  server_node_selector = "cloud"
}
```
