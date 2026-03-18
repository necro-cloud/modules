// Certificate Authority to be used with Valkey Cluster
resource "kubernetes_manifest" "certificate_authority" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.certificate_authority_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "certificate-authority"
      }
    }
    "spec" = {
      "isCA" = true
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = [var.app_name]
      }
      "commonName" = var.certificate_authority_name
      "secretName" = var.certificate_authority_name
      "duration"   = "70128h"
      "privateKey" = {
        "algorithm" = "ECDSA"
        "size"      = 256
      }
      "issuerRef" = {
        "name"  = "${var.cluster_issuer_name}"
        "kind"  = "ClusterIssuer"
        "group" = "cert-manager.io"
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

// Issuer for the Valkey Cluster
resource "kubernetes_manifest" "issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.issuer_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "issuer"
      }
    }
    "spec" = {
      "ca" = {
        "secretName" = kubernetes_manifest.certificate_authority.manifest.spec.secretName
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

// Internal Certificate for Valkey Cluster
resource "kubernetes_manifest" "internal_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.internal_certificate_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "internal-certificate"
      }
    }
    "spec" = {
      "dnsNames" = [
        # For the Primary Service
        "${kubernetes_service.primary_service.metadata[0].name}",
        "${kubernetes_service.primary_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}",
        "${kubernetes_service.primary_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local",

        # For the Replica Service
        "${kubernetes_service.replica_service.metadata[0].name}",
        "${kubernetes_service.replica_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}",
        "${kubernetes_service.replica_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local",

        # Wildcard for all StatefulSet pods
        "*.${kubernetes_service.headless_service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local",

        "127.0.0.1",
        "localhost",
      ]
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = [var.app_name]
      }
      "commonName" = var.internal_certificate_name
      "secretName" = var.internal_certificate_name
      "secretTemplate" = {
        "annotations" = {
          "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.access_namespaces
        }
      }
      "issuerRef" = {
        "name" = kubernetes_manifest.issuer.manifest.metadata.name
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

// Pushing the certificate to OpenBao for distribution
resource "kubernetes_manifest" "push_internal_certificate" {
  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "push-internal-certificate"
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      deletionPolicy  = "None"
      secretStoreRefs = [{
        name = var.cluster_secret_store_name
        kind = "ClusterSecretStore"
      }]
      selector = {
        secret = {
          name = kubernetes_manifest.internal_certificate.object.spec.secretName
        }
      }
      data = [
        {
          match = {
            remoteRef = {
              remoteKey = "${kubernetes_namespace.namespace.metadata[0].name}/certificates/${kubernetes_manifest.internal_certificate.object.spec.secretName}"
            }
          }
        }
      ]
    }
  }

  // Ensure the certificate is actually issued before trying to push it
  depends_on = [kubernetes_manifest.internal_certificate]

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
}
