// Certificate Authority to be used with MinIO Operator
resource "kubernetes_manifest" "operator_certificate_authority" {
  manifest = {

    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.operator_certificate_authority_name
      "namespace" = var.operator_namespace

      "labels" = {
        "app"       = "minio-operator"
        "component" = "ca"
      }
    }
    "spec" = {
      "isCA" = true

      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = ["MinIO Operator"]
      }
      "commonName" = var.operator_certificate_authority_name
      "secretName" = var.operator_certificate_authority_name
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
}

// Issuer for the MinIO Operator Namespace
resource "kubernetes_manifest" "operator_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"

    "metadata" = {
      "name"      = var.operator_issuer_name
      "namespace" = var.operator_namespace
      "labels" = {
        "app"       = "minio-operator"
        "component" = "issuer"
      }
    }
    "spec" = {
      "ca" = {
        "secretName" = kubernetes_manifest.operator_certificate_authority.manifest.spec.secretName
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
}

// Certificate for MinIO STS
resource "kubernetes_manifest" "operator_internal_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.operator_internal_certificate_name
      "namespace" = var.operator_namespace
      "labels" = {
        "app"       = "minio-operator"
        "component" = "certificate"
      }
    }
    "spec" = {
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = ["MinIO Operator"]
      }
      "commonName" = "sts"
      "dnsNames" = [
        "sts",
        "sts.minio-operator.svc",
        "sts.minio-operator.svc.cluster.local"
      ]
      "secretName" = var.operator_internal_certificate_name
      "issuerRef" = {
        "name" = kubernetes_manifest.operator_issuer.manifest.metadata.name
      }
    }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
}

resource "kubernetes_secret" "tenant_certificate" {
  metadata {
    name      = var.operator_tenant_certificate_name
    namespace = var.operator_namespace
    annotations = {
      "reflector.v1.k8s.emberstack.com/reflects" : "${kubernetes_namespace.namespace.metadata[0].name}/${kubernetes_manifest.internal_certificate.manifest.spec.secretName}"
    }
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.key" = ""
    "tls.crt" = ""
    "ca.crt"  = ""
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

# Restart MinIO Operator Deployment to pickup new certificates
resource "null_resource" "restart_deployment" {
  triggers = {
    "operator-certificate" : kubernetes_manifest.operator_internal_certificate.object.metadata.uid
    "tenant-certificate" : kubernetes_secret.tenant_certificate.id
  }

  provisioner "local-exec" {
    command = <<EOF
    kubectl rollout restart deployments.apps/minio-operator -n minio-operator
    kubectl rollout status deployments.apps/minio-operator -n minio-operator
    EOF
  }
}
