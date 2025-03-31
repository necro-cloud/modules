// Database Credentials to connect to the PostgreSQL Database
resource "kubernetes_secret" "database_credentials" {
  metadata {
    name      = var.database_credentials
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflects" = "${var.postgres_namespace}/${var.database_credentials}"
    }


  }

  data = {
    username = ""
    password = ""
  }

  type = "Opaque"

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

// Keycloak Credentials
resource "random_password" "keycloak_password" {
  length           = 20
  lower            = true
  numeric          = true
  special          = true
  override_special = "-_*/"
  min_special      = 3
}

resource "kubernetes_secret" "keycloak_credentials" {
  metadata {
    name      = var.keycloak_credentials
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    KC_BOOTSTRAP_ADMIN_USERNAME = "keycloak.admin"
    KC_BOOTSTRAP_ADMIN_PASSWORD = random_password.keycloak_password.result
  }

  type = "Opaque"
}

# Keycloak Realm Configuration
resource "random_password" "tester_password" {
  length           = 20
  lower            = true
  numeric          = true
  special          = true
  override_special = "-_*/"
  min_special      = 3
}

resource "kubernetes_secret" "realm_secrets" {
  metadata {
    name      = "realm-secrets"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    DISPLAY_NAME               = var.realm_settings["display_name"]
    APPLICATION_NAME           = var.realm_settings["application_name"]
    BASE_URL                   = var.realm_settings["base_url"]
    VALID_LOGIN_REDIRECT_PATH  = var.realm_settings["valid_login_redirect_path"]
    VALID_LOGOUT_REDIRECT_PATH = var.realm_settings["valid_logout_redirect_path"]
    SMTP_HOST                  = var.realm_settings["smtp_host"]
    SMTP_PORT                  = var.realm_settings["smtp_port"]
    SMTP_MAIL                  = var.realm_settings["smtp_mail"]
    SMTP_USERNAME              = var.realm_settings["smtp_username"]
    SMTP_PASSWORD              = var.realm_settings["smtp_password"]
    TESTER_SECRET              = random_password.tester_password.result
  }
}
