// Certificate Authority to be used with MinIO Tenant Cluster
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
      "secretTemplate" = {
        "annotations" = {
          "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.database_replication_namespaces
        }
      }
      "duration" = "70128h"
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

// Issuer for the MinIO Tenant Cluster
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

// Internal Certificate for MinIO Tenant Cluster
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
        "minio.minio",
        "minio.minio.svc",
        "minio.minio.svc.cluster.local",
        "*.minio.minio.svc.cluster.local",
        "*.minio-hl.minio.svc.cluster.local",
        "minio-hl.minio.svc.cluster.local",
        "*.minio.minio.minio.svc.cluster.local",
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
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.operator_namespace
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

// Kubernetes Secret for Cloudflare Tokens
resource "kubernetes_secret" "cloudflare_token" {
  metadata {
    name      = "cloudflare-token"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      "app"       = var.app_name
      "component" = "secret"
    }
  }

  data = {
    cloudflare-token = var.cloudflare_token
  }

  type = "Opaque"
}

// Cloudflare Issuer for MinIO Ingress Service
resource "kubernetes_manifest" "public_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.cloudflare_issuer_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "cloudflare-issuer"
      }
    }
    "spec" = {
      "acme" = {
        "email"  = var.cloudflare_email
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" = var.cloudflare_issuer_name
        }
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "email" = var.cloudflare_email
                "apiTokenSecretRef" = {
                  "name" = "cloudflare-token"
                  "key"  = "cloudflare-token"
                }
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [kubernetes_secret.cloudflare_token]

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

// Certificate to be used for MinIO Ingress
resource "kubernetes_manifest" "ingress_certificate" {

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.ingress_certificate_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "ingress-certificate"
      }
    }
    "spec" = {
      "duration"    = "2160h"
      "renewBefore" = "360h"
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = [var.app_name]
      }
      "privateKey" = {
        "algorithm" = "RSA"
        "encoding"  = "PKCS1"
        "size"      = "2048"
      }
      "dnsNames"   = ["${var.host_name}.${var.domain}"]
      "secretName" = var.ingress_certificate_name
      "issuerRef" = {
        "name"  = kubernetes_manifest.public_issuer.manifest.metadata.name
        "kind"  = "Issuer"
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

# Certificate to be used for MinIO API Ingress
resource "kubernetes_manifest" "api_ingress_certificate" {

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.api_ingress_certificate_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "ingress-certificate"
      }
    }
    "spec" = {
      "duration"    = "2160h"
      "renewBefore" = "360h"
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = [var.app_name]
      }
      "privateKey" = {
        "algorithm" = "RSA"
        "encoding"  = "PKCS1"
        "size"      = "2048"
      }
      "dnsNames"   = ["api.${var.host_name}.${var.domain}"]
      "secretName" = var.api_ingress_certificate_name
      "issuerRef" = {
        "name"  = kubernetes_manifest.public_issuer.manifest.metadata.name
        "kind"  = "Issuer"
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
