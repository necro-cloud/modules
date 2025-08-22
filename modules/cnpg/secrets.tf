// Garage Credentials for storing PostgreSQL PITR Backups
resource "kubernetes_secret" "garage_configuration" {
  metadata {
    name      = var.garage_configuration
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflects" = "${var.garage_namespace}/${var.garage_configuration}"
    }
  }

  data = {
    KEY_NAME          = ""
    ACCESS_KEY_ID     = ""
    SECRET_ACCESS_KEY = ""
    S3_REGION         = ""
  }

  type = "Opaque"

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

// Database credentials configuration for Keycloak
resource "random_password" "keycloak_password" {
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "keycloak_database_credentials" {
  metadata {
    name      = "credentials-keycloak"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = "keycloak"
    }
  }

  data = {
    "username" = "keycloak"
    "password" = random_password.keycloak_password.result
  }

  type = "kubernetes.io/basic-auth"
}

// Database credentials configuration for all clients
resource "random_password" "client_password" {
  count   = length(var.clients)
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "client_database_credentials" {
  count = length(var.clients)
  metadata {
    name      = "credentials-${var.clients[count.index].user}"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.clients[count.index].namespace
    }
  }

  data = {
    "username" = var.clients[count.index].user
    "password" = random_password.client_password[count.index].result
  }

  type = "kubernetes.io/basic-auth"
}


resource "random_password" "pgadmin_password" {
  length  = 20
  lower   = true
  numeric = true
  special = false
}

resource "kubernetes_secret" "pgadmin_credentials" {
  metadata {
    name      = "pgadmin-credentials"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    "PGADMIN_DEFAULT_EMAIL"    = "noreply@${var.organization_name}.com"
    "PGADMIN_DEFAULT_PASSWORD" = random_password.pgadmin_password.result
  }

  type = "Opaque"
}
