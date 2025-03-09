// Password for MinIO Admin User
resource "random_password" "root_password" {
  length           = 20
  lower            = true
  numeric          = true
  special          = true
  override_special = "-_*/"
  min_special      = 3
}

// Storage Configuration MinIO tenant
resource "kubernetes_secret" "storage_configuration" {
  metadata {
    name      = var.storage_configuration_name
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    "config.env" = <<EOF
export MINIO_ROOT_USER="${var.admin_user}"
export MINIO_ROOT_PASSWORD="${random_password.root_password.result}"
export MINIO_STORAGE_CLASS_STANDARD="EC:2"
export MINIO_BROWSER="on"
    EOF
  }

  type = "Opaque"
}

// Passwords for the postgres user
resource "random_password" "postgres_password" {
  length           = 20
  lower            = true
  numeric          = true
  special          = true
  override_special = "-_*/"
  min_special      = 3
}

// Secret configuration for the postgres user
resource "kubernetes_secret" "postgres_user_configuration" {
  metadata {
    name      = "user-configuration-postgres"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }

    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.database_replication_namespaces
    }
  }

  data = {
    CONSOLE_ACCESS_KEY = "postgres"
    CONSOLE_SECRET_KEY = random_password.postgres_password.result
  }

  type = "Opaque"
}

// Passwords for the required users
resource "random_password" "user_passwords" {
  count            = length(var.users)
  length           = 20
  lower            = true
  numeric          = true
  special          = true
  override_special = "-_*/"
  min_special      = 3
}

// Secret configuration for the required users
resource "kubernetes_secret" "user_configuration" {
  count = length(var.users)

  metadata {
    name      = "user-configuration-${var.users[count.index]}"
    namespace = kubernetes_namespace.namespace.metadata[0].name

    labels = {
      app       = var.app_name
      component = "secret"
    }
  }

  data = {
    CONSOLE_ACCESS_KEY = var.users[count.index]
    CONSOLE_SECRET_KEY = random_password.user_passwords[count.index].result
  }

  type = "Opaque"
}
