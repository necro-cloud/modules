# necronizer's cloud modules

OpenTofu Modules that can be used to deploy a functioning self hosted cloud solution perfect for side projects. For a guide on how to use these modules, please navigate to the [infrastructure](./infrastructure) directory.

# Requirements and Dependencies

The following is required to start using this repository:
1. [OpenTofu](https://opentofu.org/) - Since modules are written in OpenTofu, we deploy all components using OpenTofu
2. Kubernetes Cluster - Any kubernetes cluster can do, tested out with my [self hosted kubernetes cluster](https://github.com/necro-cloud/kubernetes)
3. [Cloudflare Token and DNS Zones](https://www.cloudflare.com/) - Currently all modules use Cloudflare for provisioning public SSL certificates using DNS01 challenge validation.
4. An SMTP Server - For sending mails using Keycloak Authentication

# Usage Instruction

The following modules have been implemented and their usage instructions written in README:
1. [MAIN MODULE] [Helm](modules/helm)
2. [OPTIONAL MODULE] [Cluster Issuer for internal certificates](modules/cluster-issuer)
3. [OPTIONAL MODULE] [Observability](modules/observability)
4. [MAIN MODULE] [OpenBao Secrets Management](modules/openbao)
5. [OPTIONAL MODULE] [Garage Storage](modules/garage)
6. [OPTIONAL MODULE] [Cloudnative PG PostgreSQL Database](modules/cnpg)
7. [OPTIONAL MODULE] [FerretDB (MongoDB) Database](modules/ferretdb)
8. [OPTIONAL MODULE] [Valkey In Memory Database](modules/valkey)
9. [OPTIONAL MODULE] [Keycloak Identity Management](modules/keycloak)
