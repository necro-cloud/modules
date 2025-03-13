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
        "*.valkey.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local",
        "valkey-primary.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local",
        "*.valkey-primary.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local",
        "*.valkey-headless.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local",
        "valkey-headless.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local",
        "127.0.0.1",
        "localhost",
        "valkey",
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
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.replication_namespaces
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
