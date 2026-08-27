## [OPTIONAL MODULE] necronizer's cloud cluster issuer module

OpenTofu Module to deploy [Cluster Issuer](https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.ClusterIssuer) for internal certificates management on the Kubernetes Cluster

Required Modules to deploy Cluster Issuer for internal certificates:
1. [Helm](../helm)

## Table of Contents
- [Providers](#providers)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.cluster_self_signed_issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name of the Self Signed Cluster Issuer | `string` | `"private-cluster-issuer"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster-issuer-name"></a> [cluster-issuer-name](#output\_cluster-issuer-name) | Name of the Cluster Issuer to be used for further certificate deployments |

## Examples

**1. Deployment of the Cluster Issuer for Internal TLS Certificates**

```terraform
# Deploy all required helm charts for deploying the infrastructure
module "helm" {
  source               = "../modules/helm"
  server_node_selector = "cloud"
}

# Setup a Cluster Issuer for all private TLS certificates
module "cluster-issuer" {
  source = "../modules/cluster-issuer"

  depends_on = [module.helm]
}
```
