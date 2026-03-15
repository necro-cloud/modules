locals {
  access_namespaces = [for config in var.clients : config.namespace]
  managed_roles = [for client in var.clients : {
    "bypassrls"       = false
    "comment"         = "${client.user} user for postgresql"
    "connectionLimit" = -1
    "createdb"        = true
    "createrole"      = true
    "ensure"          = "present"
    "inherit"         = true
    "login"           = true
    "name"            = client.user
    "passwordSecret" = {
      "name" = kubernetes_manifest.client_database_credentials_sync[client.user].object.spec.target.name
    }
    "replication" = false
    "superuser"   = false
  }]
  pgadmin_servers = {
    for index, client in concat(var.clients, [{ user = "keycloak", database = "keycloak" }]) : "${index + 1}" => {
      "Name"                = client.database
      "Group"               = "PostgreSQL Server Access",
      "Host"                = "${var.cluster_name}-rw"
      "Port"                = 5432
      "MaintenanceDB"       = client.database
      "Username"            = client.user
      "SSLMode"             = "require"
      "Comment"             = "PostgreSQL Server Access for Database: ${client.database}"
      "SSLCert"             = "/mnt/certs/${client.user}/tls.crt"
      "SSLKey"              = "/mnt/certs/${client.user}/tls.key"
      "SSLRootCert"         = "/mnt/certs/${client.user}/ca.crt"
      "PasswordExecCommand" = "cat /mnt/passwords/${client.user}/password"
    }
  }
}
