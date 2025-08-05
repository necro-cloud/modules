// Fetch Garage Certificate Authority for PITR Backups
resource "kubernetes_secret" "garage_certificate_authority" {
  metadata {
    name      = "garage-internal-certificate"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflects" : "garage/garage-internal-certificate"
    }
  }

  data = {
    "tls.crt" = ""
    "tls.key" = ""
    "ca.crt"  = ""
  }

  type = "kubernetes.io/tls"

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

# --------------- POSTGRESQL SERVER CERTIFICATES CONFIGURATION --------------- #
// Certificate Authority to be used with PostgreSQL Server
resource "kubernetes_manifest" "server_certificate_authority" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.server_certificate_authority_name
      "namespace" = var.namespace
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
        "organizationalUnits" = ["PostgreSQL"]
      }
      "commonName" = var.server_certificate_authority_name
      "secretName" = var.server_certificate_authority_name
      "secretTemplate" = {
        "annotations" = {
          "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = length(var.clients) == 0 ? "keycloak" : "keycloak,${join(",", local.replication_namespaces)}"
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

// Issuer to be used with PostgreSQL Server
resource "kubernetes_manifest" "server_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.server_issuer_name
      "namespace" = "${var.namespace}"
      "labels" = {
        "app"       = var.app_name
        "component" = "issuer"
      }
    }
    "spec" = {
      "ca" = {
        "secretName" = kubernetes_manifest.server_certificate_authority.manifest.spec.secretName
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

// Certificate for PostgreSQL Server
resource "kubernetes_manifest" "server_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.server_certificate_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "certificate"
      }
    }
    "spec" = {
      "usages" : ["server auth"]
      "dnsNames" = [
        "postgresql-cluster-rw",
        "postgresql-cluster-rw.${kubernetes_namespace.namespace.metadata[0].name}",
        "postgresql-cluster-rw.${kubernetes_namespace.namespace.metadata[0].name}.svc",
        "postgresql-cluster-r",
        "postgresql-cluster-r.${kubernetes_namespace.namespace.metadata[0].name}",
        "postgresql-cluster-r.${kubernetes_namespace.namespace.metadata[0].name}.svc",
        "postgresql-cluster-ro",
        "postgresql-cluster-ro.${kubernetes_namespace.namespace.metadata[0].name}",
        "postgresql-cluster-ro.${kubernetes_namespace.namespace.metadata[0].name}.svc"
      ]
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = ["postgres"]
      }
      "secretName" = var.server_certificate_name
      "issuerRef" = {
        "name" = kubernetes_manifest.server_issuer.manifest.metadata.name
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

# --------------- POSTGRESQL CLIENT CERTIFICATES CONFIGURATION --------------- #
// Certificate Authority to be used with PostgreSQL Client
resource "kubernetes_manifest" "client_certificate_authority" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.client_certificate_authority_name
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
        "organizationalUnits" = ["PostgreSQL"]
      }
      "commonName" = var.client_certificate_authority_name
      "secretName" = var.client_certificate_authority_name
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

// Issuer to be used with PostgreSQL Client
resource "kubernetes_manifest" "client_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = var.client_issuer_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "issuer"
      }
    }
    "spec" = {
      "ca" = {
        "secretName" = kubernetes_manifest.client_certificate_authority.manifest.spec.secretName
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

// Certificate for Streaming Replica
resource "kubernetes_manifest" "client_streaming_replica_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.client_streaming_replica_certificate_name
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "certificate"
      }
    }
    "spec" = {
      "usages" : ["client auth"]
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = ["PostgreSQL"]
      }
      "commonName" = "streaming_replica"
      "secretName" = var.client_streaming_replica_certificate_name
      "issuerRef" = {
        "name" = kubernetes_manifest.client_issuer.manifest.metadata.name
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

// Certificate for Keycloak User
resource "kubernetes_manifest" "client_keycloak_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "postgresql-keycloak-client-certificate"
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "certificate"
      }
    }
    "spec" = {
      "usages" : ["client auth"]
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = ["PostgreSQL"]
      }
      "commonName" = "keycloak"
      "secretName" = "postgresql-keycloak-client-certificate"
      "secretTemplate" = {
        "annotations" = {
          "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = "keycloak"
        }
      }
      "additionalOutputFormats" = [
        {
          "type" : "DER"
        }
      ]
      "privateKey" = {
        "encoding" = "PKCS8"
      }
      "issuerRef" = {
        "name" = kubernetes_manifest.client_issuer.manifest.metadata.name
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

// Certificates for all clients
resource "kubernetes_manifest" "client_certificates" {
  count = length(var.clients)
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "postgresql-${var.clients[count.index].user}-client-certificate"
      "namespace" = kubernetes_namespace.namespace.metadata[0].name
      "labels" = {
        "app"       = var.app_name
        "component" = "certificate"
      }
    }
    "spec" = {
      "usages" : ["client auth"]
      "subject" = {
        "organizations"       = [var.organization_name]
        "countries"           = [var.country_name]
        "organizationalUnits" = ["PostgreSQL"]
      }
      "commonName" = var.clients[count.index].user
      "secretName" = "postgresql-${var.clients[count.index].user}-client-certificate"
      "secretTemplate" = {
        "annotations" = {
          "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.clients[count.index].namespace
        }
      }
      "additionalOutputFormats" = var.clients[count.index].derRequired ? [
        {
          "type" : "DER"
        }
      ] : []
      "privateKey" = {
        "encoding" = var.clients[count.index].privateKeyEncoding
      }
      "issuerRef" = {
        "name" = kubernetes_manifest.client_issuer.manifest.metadata.name
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
