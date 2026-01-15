# necronizer's cloud guide to use OpenTofu modules

This directory mainly contains OpenTofu files on how to use the [modules](https://github.com/necro-cloud/modules) for deploying a self hosted cloud solution perfect for side projects and also is used for testing out modules when new features are being worked on.

# Requirements and Dependencies

The following is required to start using this repository:
1. [OpenTofu](https://opentofu.org/) - Since modules are written in OpenTofu, we deploy all components using OpenTofu
2. Kubernetes Cluster - Any kubernetes cluster can do, tested out with my [self hosted kubernetes cluster](https://github.com/necro-cloud/kubernetes)
3. [Cloudflare Token and DNS Zones](https://www.cloudflare.com/) - Currently all modules use Cloudflare for provisioning public SSL certificates using DNS01 challenge validation.
4. An SMTP Server - For sending mails using Keycloak Authentication

# Usage Instructions:

**Step 1:** Setup a TFVARS file, an example for which is given [here](terraform-example.tfvars.json) which will require SMTP Server details to be added along with [Cloudflare Token](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/#api-tokens) and DNS to be used. Save the file as `terraform.tfvars.json`.

**Step 2:** Initialize the state with OpenTofu by running the following command: `tofu init`

**Step 3:** Deploy all required CRDs using OpenTofu by executing the following command: `tofu apply --target=module.helm -var-file terraform.tfvars.json -auto-approve`

**Step 4:** Now you can deploy all components using OpenTofu by executing the following command: `tofu apply -var-file terraform.tfvars.json -auto-approve`
