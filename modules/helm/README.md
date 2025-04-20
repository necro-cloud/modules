<!-- BEGIN_TF_DOCS -->
## necronizer's cloud required helm charts module

OpenTofu Module to deploy the following required helm charts:
1. [Cert-Manager](https://cert-manager.io/)
2. [Cloudnative PG](https://cloudnative-pg.io/)
1. [NGINX Ingress](https://github.com/kubernetes/ingress-nginx)
1. [MinIO Operator](https://min.io/docs/minio/kubernetes/upstream/operations/installation.html)
1. [Kubernetes Reflector](https://github.com/emberstack/kubernetes-reflector)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.0-pre2 |

## Resources

| Name | Type |
|------|------|
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cnpg](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.minio](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.reflector](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_configuration"></a> [cert\_manager\_configuration](#input\_cert\_manager\_configuration) | Dictionary filled with Cert Manager Operator Configuration Details | `map(string)` | <pre>{<br/>  "chart": "cert-manager",<br/>  "create_namespace": true,<br/>  "name": "cert-manager",<br/>  "namespace": "cert-manager",<br/>  "repository": "https://charts.jetstack.io",<br/>  "version": "v1.17.1"<br/>}</pre> | no |
| <a name="input_cnpg_configuration"></a> [cnpg\_configuration](#input\_cnpg\_configuration) | Dictionary filled with Cloud Native PG Operator Configuration Details | `map(string)` | <pre>{<br/>  "chart": "cloudnative-pg",<br/>  "create_namespace": true,<br/>  "name": "cnpg",<br/>  "namespace": "cnpg-system",<br/>  "repository": "https://cloudnative-pg.github.io/charts",<br/>  "version": "v0.23.2"<br/>}</pre> | no |
| <a name="input_minio_operator_configuration"></a> [minio\_operator\_configuration](#input\_minio\_operator\_configuration) | Dictionary filled with MinIO Operator Configuration Details | `map(string)` | <pre>{<br/>  "chart": "operator",<br/>  "create_namespace": true,<br/>  "name": "minio-operator",<br/>  "namespace": "minio-operator",<br/>  "repository": "https://operator.min.io",<br/>  "version": "7.0.0"<br/>}</pre> | no |
| <a name="input_nginx_configuration"></a> [nginx\_configuration](#input\_nginx\_configuration) | Dictionary filled with NGINX Controller Configuration Details | `map(string)` | <pre>{<br/>  "chart": "ingress-nginx",<br/>  "create_namespace": true,<br/>  "name": "ingress-nginx",<br/>  "namespace": "ingress-nginx",<br/>  "repository": "https://kubernetes.github.io/ingress-nginx",<br/>  "version": "4.12.0"<br/>}</pre> | no |
| <a name="input_reflector_configuration"></a> [reflector\_configuration](#input\_reflector\_configuration) | Dictionary filled with Kubernetes Reflector Configuration Details | `map(string)` | <pre>{<br/>  "chart": "reflector",<br/>  "create_namespace": true,<br/>  "name": "reflector",<br/>  "namespace": "reflector",<br/>  "repository": "https://emberstack.github.io/helm-charts",<br/>  "version": "v9.0.320"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_minio-operator-namespace"></a> [minio-operator-namespace](#output\_minio-operator-namespace) | Namespace where the MinIO Operator is deployed in |
<!-- END_TF_DOCS -->
